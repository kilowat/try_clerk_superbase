import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHandler {
  static final _singleton = ConnectivityHandler._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _connectionChangeStatusController =
      StreamController();

  final Connectivity _connectivity = Connectivity();

  Stream<bool> get stream => _connectionChangeStatusController.stream;

  ConnectivityHandler._internal();

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  factory ConnectivityHandler() {
    return _singleton;
  }

  dispose() {
    _subscription?.cancel();
    _connectionChangeStatusController.close();
  }

  void initialize() async {
    assert(_subscription == null, 'Already connectivity handler initialized');
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);

    _connectivityListener();
  }

  void _connectivityListener() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = !result.contains(ConnectivityResult.none);
      _connectionChangeStatusController.add(_isConnected);
    });
  }
}
