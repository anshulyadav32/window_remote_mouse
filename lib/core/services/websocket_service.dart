import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketService {
  final Logger _logger;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  int _reconnectAttempts = 0;
  bool _isManualDisconnect = false;
  
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  WebSocketService(this._logger);
  
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentStatus => _currentStatus;
  
  Future<bool> connect(String serverAddress, {String? token}) async {
    if (_currentStatus == ConnectionStatus.connected || 
        _currentStatus == ConnectionStatus.connecting) {
      return true;
    }
    
    _isManualDisconnect = false;
    _updateStatus(ConnectionStatus.connecting);
    
    try {
      final uri = Uri.parse('ws://$serverAddress${AppConstants.websocketPath}');
      _logger.i('Connecting to WebSocket: $uri');
      
      _channel = WebSocketChannel.connect(
        uri,
        protocols: token != null ? ['Bearer', token] : null,
      );
      
      await _channel!.ready.timeout(AppConstants.connectionTimeout);
      
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );
      
      _updateStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
      _logger.i('WebSocket connected successfully');
      return true;
      
    } catch (e) {
      _logger.e('WebSocket connection failed: $e');
      _updateStatus(ConnectionStatus.error);
      _scheduleReconnect();
      return false;
    }
  }
  
  Future<void> disconnect() async {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    await _subscription?.cancel();
    await _channel?.sink.close(status.normalClosure);
    
    _channel = null;
    _subscription = null;
    _reconnectAttempts = 0;
    
    _updateStatus(ConnectionStatus.disconnected);
    _logger.i('WebSocket disconnected');
  }
  
  bool sendMessage(Map<String, dynamic> message) {
    if (_currentStatus != ConnectionStatus.connected || _channel == null) {
      _logger.w('Cannot send message: WebSocket not connected');
      return false;
    }
    
    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      _logger.d('Message sent: $jsonMessage');
      return true;
    } catch (e) {
      _logger.e('Failed to send message: $e');
      return false;
    }
  }
  
  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      _logger.d('Message received: $data');
      
      // Handle heartbeat response
      if (data['type'] == 'pong') {
        return;
      }
      
      _messageController.add(data);
    } catch (e) {
      _logger.e('Failed to parse message: $e');
    }
  }
  
  void _onError(error) {
    _logger.e('WebSocket error: $error');
    _updateStatus(ConnectionStatus.error);
    
    if (!_isManualDisconnect) {
      _scheduleReconnect();
    }
  }
  
  void _onDisconnected() {
    _logger.w('WebSocket disconnected');
    _heartbeatTimer?.cancel();
    
    if (!_isManualDisconnect) {
      _updateStatus(ConnectionStatus.reconnecting);
      _scheduleReconnect();
    } else {
      _updateStatus(ConnectionStatus.disconnected);
    }
  }
  
  void _scheduleReconnect() {
    if (_isManualDisconnect || 
        _reconnectAttempts >= AppConstants.maxReconnectAttempts) {
      _updateStatus(ConnectionStatus.error);
      return;
    }
    
    _reconnectAttempts++;
    _logger.i('Scheduling reconnect attempt $_reconnectAttempts');
    
    _reconnectTimer = Timer(AppConstants.reconnectDelay, () {
      // Will need server address from repository
      // This is a simplified version - in real implementation,
      // the service would get the server address from storage
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentStatus == ConnectionStatus.connected) {
        sendMessage({'type': 'ping', 'timestamp': DateTime.now().millisecondsSinceEpoch});
      }
    });
  }
  
  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
  
  void dispose() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _statusController.close();
    _messageController.close();
  }
}