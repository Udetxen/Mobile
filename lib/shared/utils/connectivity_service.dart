import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity;

  bool hasConnections = false;
  bool get isConnected => hasConnections;

  ConnectivityService(this._connectivity);

  Future<void> initialize() async {
    await _checkConnection();
    _listenToConnectionChanges();
  }

  Future<void> _checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    hasConnections = !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> _listenToConnectionChanges() async {
    _connectivity.onConnectivityChanged.listen((connectivityResult) {
      hasConnections = !connectivityResult.contains(ConnectivityResult.none);

      notifyListeners();
    });
  }
}
