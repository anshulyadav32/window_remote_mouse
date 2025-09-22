import '../repositories/connection_repository.dart';

class DisconnectFromServer {
  final ConnectionRepository _repository;
  
  DisconnectFromServer(this._repository);
  
  Future<DisconnectResult> call() async {
    try {
      if (!_repository.isConnected) {
        return DisconnectResult.success('Already disconnected');
      }
      
      await _repository.disconnect();
      return DisconnectResult.success('Disconnected successfully');
      
    } catch (e) {
      return DisconnectResult.failure('Failed to disconnect: ${e.toString()}');
    }
  }
}

class DisconnectResult {
  final bool isSuccess;
  final String message;
  
  const DisconnectResult._({
    required this.isSuccess,
    required this.message,
  });
  
  factory DisconnectResult.success(String message) => DisconnectResult._(
    isSuccess: true,
    message: message,
  );
  
  factory DisconnectResult.failure(String message) => DisconnectResult._(
    isSuccess: false,
    message: message,
  );
}