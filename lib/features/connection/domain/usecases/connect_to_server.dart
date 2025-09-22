import '../repositories/connection_repository.dart';

class ConnectToServer {
  final ConnectionRepository _repository;
  
  ConnectToServer(this._repository);
  
  Future<ConnectResult> call(ConnectParams params) async {
    try {
      // Validate server address
      if (params.serverAddress.isEmpty) {
        return ConnectResult.failure('Server address cannot be empty');
      }
      
      if (!_isValidServerAddress(params.serverAddress)) {
        return ConnectResult.failure('Invalid server address format');
      }
      
      // Test connection first if requested
      if (params.testFirst) {
        final canConnect = await _repository.testConnection(params.serverAddress);
        if (!canConnect) {
          return ConnectResult.failure('Cannot reach server at ${params.serverAddress}');
        }
      }
      
      // Attempt connection
      final success = await _repository.connect(
        params.serverAddress,
        token: params.token,
      );
      
      if (success) {
        // Save to history and as last connected
        await _repository.saveToHistory(params.serverAddress);
        await _repository.saveLastServerAddress(params.serverAddress);
        
        return ConnectResult.success();
      } else {
        return ConnectResult.failure('Failed to connect to server');
      }
      
    } catch (e) {
      return ConnectResult.failure('Connection error: ${e.toString()}');
    }
  }
  
  bool _isValidServerAddress(String address) {
    // Basic validation for IP:PORT or hostname:PORT format
    final regex = RegExp(r'^[a-zA-Z0-9.-]+:\d+$');
    return regex.hasMatch(address);
  }
}

class ConnectParams {
  final String serverAddress;
  final String? token;
  final bool testFirst;
  
  const ConnectParams({
    required this.serverAddress,
    this.token,
    this.testFirst = true,
  });
}

class ConnectResult {
  final bool isSuccess;
  final String? errorMessage;
  
  const ConnectResult._({
    required this.isSuccess,
    this.errorMessage,
  });
  
  factory ConnectResult.success() => const ConnectResult._(isSuccess: true);
  
  factory ConnectResult.failure(String message) => ConnectResult._(
    isSuccess: false,
    errorMessage: message,
  );
}