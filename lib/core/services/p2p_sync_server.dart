import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/models/device.dart';
import '../../domain/models/sync_models.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/sync_merge_engine.dart';
import '../utils/uuid_generator.dart';
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
  final Map<String, DateTime> _pendingChallenges = <String, DateTime>{};
  Future<void> _syncMutex = Future<void>.value();

  int? get port => _server?.port;
  bool get isRunning => _server != null;

  static const Duration _challengeTtl = Duration(minutes: 2);

  Future<T> _withSyncLock<T>(Future<T> Function() action) {
    final prev = _syncMutex;
    final completer = Completer<void>();
    _syncMutex = completer.future;
    return prev.then((_) => action()).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }

  String _issueChallenge() {
    final now = DateTime.now();
    _pendingChallenges.removeWhere((_, exp) => now.isAfter(exp));
    while (_pendingChallenges.length >= 200) {
      _pendingChallenges.remove(_pendingChallenges.keys.first);
    }
    final challenge = UuidGenerator.v4();
    _pendingChallenges[challenge] = now.add(_challengeTtl);
    return challenge;
  }

  bool _consumeChallenge(String challenge) {
    final expiry = _pendingChallenges.remove(challenge);
    if (expiry == null) return false;
    return !DateTime.now().isAfter(expiry);
  }

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

      if (request.method == 'GET' && request.uri.path == '/challenge') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'challenge': _issueChallenge()}));
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
      final decrypted = cryptoService.decryptEnvelopeWithMeta(
        rawEnvelope: body,
        expectedWorkspaceId: workspace.id,
        workspaceKey: workspace.workspaceKey,
        consumeChallenge: _consumeChallenge,
      );
      final incomingSnapshot = decrypted.snapshot;

      final encryptedResponse = await _withSyncLock(() async {
        final localDevices = await deviceRepository.getAllDevices();
        final sender = localDevices
            .where((d) => d.id == incomingSnapshot.senderDeviceId)
            .firstOrNull;
        final incomingSender = incomingSnapshot.devices
            .where((d) => d.id == incomingSnapshot.senderDeviceId)
            .firstOrNull;
        final isSenderRevoked =
            (sender != null && sender.isRevoked) ||
                (incomingSender != null && incomingSender.isRevoked);
        // Newly QR-paired peers only hold their own device row until their first
        // sync; allow authenticated workspace peers present in incomingSnapshot.
        if (isSenderRevoked || (sender == null && incomingSender == null)) {
          return null;
        }

        await _applyIncomingSnapshot(
          localDevice: localDevice,
          localDevices: localDevices,
          incoming: incomingSnapshot,
        );

        final updatedDevices = await deviceRepository.getAllDevices();
        final updatedProducts =
            await productRepository.getAllProductsIncludingDeleted();
        final updatedProductTypes =
            await productRepository.getAllProductTypesIncludingArchived();
        final responseSnapshot = SyncSnapshot(
          workspaceId: workspace.id,
          senderDeviceId: localDevice.id,
          generatedAt: DateTime.now(),
          devices: updatedDevices,
          products: updatedProducts,
          productTypes: updatedProductTypes,
        );

        return cryptoService.encryptEnvelope(
          snapshot: responseSnapshot,
          workspaceKey: workspace.workspaceKey,
          replyTo: decrypted.nonce,
        );
      });

      if (encryptedResponse == null) {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write('Device is not paired or has been revoked.');
        await request.response.close();
        return;
      }

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
    if (peerRecord != null && peerRecord.isRevoked) {
      throw const P2pSyncException(
        'Peer is not paired in this workspace or has been revoked.',
      );
    }

    final localProducts =
        await productRepository.getAllProductsIncludingDeleted();
    final localProductTypes =
        await productRepository.getAllProductTypesIncludingArchived();
    final outgoing = SyncSnapshot(
      workspaceId: workspace.id,
      senderDeviceId: localDevice.id,
      generatedAt: DateTime.now(),
      devices: localDevices,
      products: localProducts,
      productTypes: localProductTypes,
    );

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final challengeReq = await client
          .get(peer.host, peer.port, '/challenge')
          .timeout(const Duration(seconds: 5));
      final challengeResp =
          await challengeReq.close().timeout(const Duration(seconds: 5));
      final challengeBody = await utf8.decoder.bind(challengeResp).join();
      if (challengeResp.statusCode != HttpStatus.ok) {
        throw P2pSyncException(
          'Peer challenge failed (${challengeResp.statusCode}): $challengeBody',
        );
      }
      final challengeJson = jsonDecode(challengeBody) as Map<String, dynamic>;
      final challenge = challengeJson['challenge'] as String;

      final requestNonce = UuidGenerator.v4();
      final payloadWithChallenge = cryptoService.encryptEnvelope(
        snapshot: outgoing,
        workspaceKey: workspace.workspaceKey,
        nonce: requestNonce,
        challenge: challenge,
      );

      final request = await client
          .post(peer.host, peer.port, '/sync')
          .timeout(const Duration(seconds: 5));
      request.headers.contentType = ContentType.json;
      request.write(payloadWithChallenge);

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
        expectedReplyTo: requestNonce,
      );

      final pushedIds = localProducts
          .where((p) => p.hasPendingLocalEdit)
          .map((p) => p.id)
          .toList();

      final result = await _withSyncLock(() async {
        final currentDevices = await deviceRepository.getAllDevices();
        return _applyIncomingSnapshot(
          localDevice: localDevice,
          localDevices: currentDevices,
          incoming: incomingSnapshot,
          pushedPendingProductIds: pushedIds,
        );
      });
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
    List<String> pushedPendingProductIds = const [],
  }) async {
    final localProducts =
        await productRepository.getAllProductsIncludingDeleted();
    final localProductTypes =
        await productRepository.getAllProductTypesIncludingArchived();
    final result = mergeEngine.merge(
      localDevice: localDevice,
      localDevices: localDevices,
      localProducts: localProducts,
      localProductTypes: localProductTypes,
      incoming: incoming,
    );

    await productRepository.runInTransaction(() async {
      for (final device in result.updatedDevices) {
        await deviceRepository.upsertDevice(device);
      }

      if (result.replaceProductTypes) {
        await productRepository
            .applySyncedProductTypesAtomically(result.productTypesToSave);
      }

      await productRepository.applySyncedProductsAtomically(result.productsToSave);
      if (pushedPendingProductIds.isNotEmpty) {
        await productRepository.clearPendingLocalEdits(pushedPendingProductIds);
      }
      await productRepository.saveConflictRecords(result.newConflicts);
    });

    if (result.localDeviceRevoked) {
      onLocalDeviceRevoked?.call();
    }

    return result;
  }
}
