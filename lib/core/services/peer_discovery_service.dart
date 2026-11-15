import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nsd/nsd.dart' as nsd;

import '../../domain/models/sync_models.dart';

abstract class PeerDiscoveryService {
  Stream<List<DiscoveredPeer>> get peersStream;
  List<DiscoveredPeer> get currentPeers;

  Future<void> start({
    required String workspaceId,
    required String localDeviceId,
    required String localDisplayName,
    required int port,
  });

  Future<void> stop();
}

class NsdPeerDiscoveryService implements PeerDiscoveryService {
  static const String serviceType = '_synprod._tcp';

  final _peersController = StreamController<List<DiscoveredPeer>>.broadcast();
  final Map<String, DiscoveredPeer> _peersByDeviceId = <String, DiscoveredPeer>{};

  nsd.Registration? _registration;
  nsd.Discovery? _discovery;
  String? _workspaceId;
  String? _localDeviceId;
  bool _isStopping = false;

  @override
  Stream<List<DiscoveredPeer>> get peersStream => _peersController.stream;

  @override
  List<DiscoveredPeer> get currentPeers =>
      List.unmodifiable(_peersByDeviceId.values);

  @override
  Future<void> start({
    required String workspaceId,
    required String localDeviceId,
    required String localDisplayName,
    required int port,
  }) async {
    await stop();
    _isStopping = false;
    _workspaceId = workspaceId;
    _localDeviceId = localDeviceId;

    final shortId =
        localDeviceId.length >= 6 ? localDeviceId.substring(0, 6) : localDeviceId;
    final serviceName = 'SynProd-$shortId';

    _registration = await nsd.register(
      nsd.Service(
        name: serviceName,
        type: serviceType,
        port: port,
        txt: {
          'wid': utf8.encode(workspaceId),
          'did': utf8.encode(localDeviceId),
          'dn': utf8.encode(localDisplayName),
        },
      ),
    );

    _discovery = await nsd.startDiscovery(
      serviceType,
      ipLookupType: nsd.IpLookupType.v4,
    );
    _discovery!.addServiceListener(_onServiceStatusChanged);
  }

  void _onServiceStatusChanged(
    nsd.Service service,
    nsd.ServiceStatus status,
  ) {
    if (_isStopping) return;

    final txt = service.txt;
    if (txt == null) return;

    final widBytes = txt['wid'];
    final didBytes = txt['did'];
    final dnBytes = txt['dn'];
    if (widBytes == null || didBytes == null) return;

    final workspaceId = utf8.decode(widBytes);
    final deviceId = utf8.decode(didBytes);
    final displayName =
        dnBytes != null ? utf8.decode(dnBytes) : (service.name ?? 'Peer');

    if (workspaceId != _workspaceId || deviceId == _localDeviceId) {
      return;
    }

    if (status == nsd.ServiceStatus.lost) {
      if (_peersByDeviceId.remove(deviceId) != null) {
        _peersController.add(currentPeers);
      }
      return;
    }

    final addresses = service.addresses;
    final host = (addresses != null && addresses.isNotEmpty)
        ? addresses.firstWhere(
            (addr) => addr.type == InternetAddressType.IPv4,
            orElse: () => addresses.first,
          ).address
        : service.host;
    final port = service.port;

    if (host == null || host.isEmpty || port == null || port <= 0) {
      return;
    }

    _peersByDeviceId[deviceId] = DiscoveredPeer(
      deviceId: deviceId,
      displayName: displayName,
      workspaceId: workspaceId,
      host: host,
      port: port,
      discoveredAt: DateTime.now(),
    );
    _peersController.add(currentPeers);
  }

  @override
  Future<void> stop() async {
    _isStopping = true;
    final discovery = _discovery;
    _discovery = null;
    if (discovery != null) {
      discovery.removeServiceListener(_onServiceStatusChanged);
      try {
        await nsd.stopDiscovery(discovery);
      } catch (_) {}
    }

    final registration = _registration;
    _registration = null;
    if (registration != null) {
      try {
        await nsd.unregister(registration);
      } catch (_) {}
    }

    if (_peersByDeviceId.isNotEmpty) {
      _peersByDeviceId.clear();
      if (!_peersController.isClosed) {
        _peersController.add(const []);
      }
    }
  }
}
