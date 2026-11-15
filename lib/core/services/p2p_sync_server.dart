import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/models/device.dart';
import '../../domain/models/sync_models.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/sync_merge_engine.dart';
import 'sync_crypto_service.dart';

class P2pSyncException implements Exception {
  final String message;
  const P2pSyncException(this.message);

  @override
  String toString() => message;
}

class P2pSyncServer {
  final DeviceRepository deviceRepository;
  final ProductRepository productRepository;
  final SyncCryptoService cryptoService;
  final SyncMergeEngine mergeEngine;
  final String Function() getLocalDeviceId;
  final void Function()? onLocalDeviceRevoked;
  final void Function()? onSyncCompleted;

  HttpServer? _server;
  int? get port => _server?.port;
  bool get isRunning => _server != null;

  P2pSyncServer({
    required this.deviceRepository,
    required this.productRepository,
    required this.getLocalDeviceId,
    SyncCryptoService? cryptoService,
    SyncMergeEngine? mergeEngine,
    this.onLocalDeviceRevoked,
    this.onSyncCompleted,
  })  : cryptoService = cryptoService ?? SyncCryptoService(),
        mergeEngine = mergeEngine ?? SyncMergeEngine();

  Future<int> start({
    InternetAddress? bindAddress,
    int port = 0,
  }) async {
    await stop();
    final server = await HttpServer.bind(
      bindAddress ?? InternetAddress.anyIPv4,
      port,
    );
    _server = server;
    server.listen(_handleRequest);
    return server.port;
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    if (server != null) {
      await server.close(force: true);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method == 'GET' && request.uri.path == '/health') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'status': 'ok', 'deviceId': getLocalDeviceId()}));
        await request.response.close();
        return;
      }

      if (request.method != 'POST' || request.uri.path != '/sync') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final workspace = await deviceRepository.getActiveWorkspace();
      final localDeviceId = getLocalDeviceId();
      final localDevice = await deviceRepository.getDeviceById(localDeviceId);
      if (workspace == null || localDevice == null || localDevice.isRevoked) {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        return;
      }

      final body = await utf8.decoder.bind(request).join();
      final incomingSnapshot = cryptoService.decryptEnvelope(
        rawEnvelope: body,
        expectedWorkspaceId: workspace.id,
        workspaceKey: workspace.workspaceKey,
      );

      final localDevices = await deviceRepository.getAllDevices();
      final sender = localDevices
          .where((d) => d.id == incomingSnapshot.senderDeviceId)
          .firstOrNull;
      if (sender == null || sender.isRevoked) {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write('Device is not paired or has been revoked.');
        await request.response.close();
        return;
      }

      await _applyIncomingSnapshot(
        localDevice: localDevice,
        localDevices: localDevices,
        incoming: incomingSnapshot,
      );

      final updatedDevices = await deviceRepository.getAllDevices();
      final updatedProducts =
          await productRepository.getAllProductsIncludingDeleted();
      final responseSnapshot = SyncSnapshot(
        workspaceId: workspace.id,
        senderDeviceId: localDevice.id,
        generatedAt: DateTime.now(),
        devices: updatedDevices,
        products: updatedProducts,
      );

      final encryptedResponse = cryptoService.encryptEnvelope(
        snapshot: responseSnapshot,
        workspaceKey: workspace.workspaceKey,
      );

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(encryptedResponse);
      await request.response.close();
      onSyncCompleted?.call();
    } on SyncCryptoException catch (e) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..write(e.message);
      await request.response.close();
    } catch (_) {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }

  Future<SyncMergeResult> syncWithPeer(DiscoveredPeer peer) async {
    final workspace = await deviceRepository.getActiveWorkspace();
    final localDeviceId = getLocalDeviceId();
    final localDevice = await deviceRepository.getDeviceById(localDeviceId);

    if (workspace == null || localDevice == null) {
      throw const P2pSyncException('Workspace or local device is not configured.');
    }
    if (localDevice.isRevoked) {
      throw const P2pSyncException('This device has been revoked.');
    }
    if (peer.workspaceId != workspace.id) {
      throw const P2pSyncException('Peer belongs to a different workspace.');
    }

    final localDevices = await deviceRepository.getAllDevices();
    final peerRecord =
        localDevices.where((d) => d.id == peer.deviceId).firstOrNull;
    if (peerRecord == null || peerRecord.isRevoked) {
      throw const P2pSyncException(
        'Peer is not paired in this workspace or has been revoked.',
      );
    }

    final localProducts =
        await productRepository.getAllProductsIncludingDeleted();
    final outgoing = SyncSnapshot(
      workspaceId: workspace.id,
      senderDeviceId: localDevice.id,
      generatedAt: DateTime.now(),
      devices: localDevices,
      products: localProducts,
    );

    final encryptedPayload = cryptoService.encryptEnvelope(
      snapshot: outgoing,
      workspaceKey: workspace.workspaceKey,
    );

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client
          .post(peer.host, peer.port, '/sync')
          .timeout(const Duration(seconds: 5));
      request.headers.contentType = ContentType.json;
      request.write(encryptedPayload);

      final response = await request.close().timeout(const Duration(seconds: 8));
      final responseBody = await utf8.decoder.bind(response).join();

      if (response.statusCode != HttpStatus.ok) {
        throw P2pSyncException(
          'Peer rejected sync (${response.statusCode}): $responseBody',
        );
      }

      final incomingSnapshot = cryptoService.decryptEnvelope(
        rawEnvelope: responseBody,
        expectedWorkspaceId: workspace.id,
        workspaceKey: workspace.workspaceKey,
      );

      final result = await _applyIncomingSnapshot(
        localDevice: localDevice,
        localDevices: localDevices,
        incoming: incomingSnapshot,
      );
      onSyncCompleted?.call();
      return result;
    } finally {
      client.close(force: true);
    }
  }

  Future<SyncMergeResult> _applyIncomingSnapshot({
    required Device localDevice,
    required List<Device> localDevices,
    required SyncSnapshot incoming,
  }) async {
    final localProducts =
        await productRepository.getAllProductsIncludingDeleted();
    final result = mergeEngine.merge(
      localDevice: localDevice,
      localDevices: localDevices,
      localProducts: localProducts,
      incoming: incoming,
    );

    for (final device in result.updatedDevices) {
      await deviceRepository.upsertDevice(device);
    }

    await productRepository.applySyncedProductsAtomically(result.productsToSave);
    await productRepository.saveConflictRecords(result.newConflicts);

    if (result.localDeviceRevoked) {
      onLocalDeviceRevoked?.call();
    }

    return result;
  }
}
