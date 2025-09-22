import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final Logger _logger = Logger();
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  
  ConnectivityService(this._connectivity);
  
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;
  
  bool get isConnected => _currentStatus != ConnectivityStatus.none;
  bool get isWifi => _currentStatus == ConnectivityStatus.wifi;
  bool get isMobile => _currentStatus == ConnectivityStatus.mobile;
  
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        _logger.e('Connectivity error: $error');
      },
    );
  }
  
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      _logger.e('Failed to check connectivity: $e');
      _updateStatus(ConnectivityStatus.unknown);
    }
  }
  
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    ConnectivityStatus status;
    
    if (results.isEmpty) {
      status = ConnectivityStatus.none;
    } else if (results.contains(ConnectivityResult.wifi)) {
      status = ConnectivityStatus.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      status = ConnectivityStatus.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      status = ConnectivityStatus.ethernet;
    } else if (results.contains(ConnectivityResult.none)) {
      status = ConnectivityStatus.none;
    } else {
      status = ConnectivityStatus.other;
    }
    
    _updateStatus(status);
  }
  
  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      final previousStatus = _currentStatus;
      _currentStatus = status;
      
      _logger.i('Connectivity changed: ${previousStatus.name} -> ${status.name}');
      _statusController.add(status);
    }
  }
  
  Future<bool> hasInternetAccess() async {
    if (!isConnected) return false;
    
    try {
      // Simple connectivity test - in production, you might want to ping your server
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      _logger.e('Internet access check failed: $e');
      return false;
    }
  }
  
  String getConnectionTypeDescription() {
    switch (_currentStatus) {
      case ConnectivityStatus.wifi:
        return 'Wi-Fi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.other:
        return 'Other';
      case ConnectivityStatus.none:
        return 'No Connection';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }
  
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

enum ConnectivityStatus {
  wifi,
  mobile,
  ethernet,
  other,
  none,
  unknown,
}