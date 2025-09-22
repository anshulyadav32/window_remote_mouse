import '../entities/connection_state.dart';
import '../entities/mouse_command.dart';

abstract class ConnectionRepository {
  /// Stream of connection state changes
  Stream<ConnectionState> get connectionStateStream;
  
  /// Current connection state
  ConnectionState get currentState;
  
  /// Connect to the remote server
  Future<bool> connect(String serverAddress, {String? token});
  
  /// Disconnect from the remote server
  Future<void> disconnect();
  
  /// Send a mouse command to the server
  Future<bool> sendMouseCommand(MouseCommand command);
  
  /// Check if currently connected
  bool get isConnected;
  
  /// Get connection history
  Future<List<String>> getConnectionHistory();
  
  /// Save server address to history
  Future<void> saveToHistory(String serverAddress);
  
  /// Test server connectivity
  Future<bool> testConnection(String serverAddress);
  
  /// Get last connected server address
  Future<String?> getLastServerAddress();
  
  /// Save last connected server address
  Future<void> saveLastServerAddress(String serverAddress);
}