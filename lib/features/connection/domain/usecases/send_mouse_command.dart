import '../entities/mouse_command.dart';
import '../repositories/connection_repository.dart';

class SendMouseCommand {
  final ConnectionRepository _repository;
  
  SendMouseCommand(this._repository);
  
  Future<SendCommandResult> call(SendCommandParams params) async {
    try {
      // Check if connected
      if (!_repository.isConnected) {
        return SendCommandResult.failure('Not connected to server');
      }
      
      // Validate command
      final validationResult = _validateCommand(params.command);
      if (!validationResult.isValid) {
        return SendCommandResult.failure(validationResult.errorMessage!);
      }
      
      // Apply sensitivity if it's a move command
      MouseCommand commandToSend = params.command;
      if (params.command.type == MouseCommandType.move && params.sensitivity != null) {
        commandToSend = MouseCommand.move(
          deltaX: params.command.deltaX! * params.sensitivity!,
          deltaY: params.command.deltaY! * params.sensitivity!,
          timestamp: params.command.timestamp,
        );
      }
      
      // Send command
      final success = await _repository.sendMouseCommand(commandToSend);
      
      if (success) {
        return SendCommandResult.success();
      } else {
        return SendCommandResult.failure('Failed to send command');
      }
      
    } catch (e) {
      return SendCommandResult.failure('Error sending command: ${e.toString()}');
    }
  }
  
  CommandValidationResult _validateCommand(MouseCommand command) {
    switch (command.type) {
      case MouseCommandType.move:
        if (command.deltaX == null || command.deltaY == null) {
          return CommandValidationResult.invalid('Move command requires deltaX and deltaY');
        }
        break;
        
      case MouseCommandType.click:
      case MouseCommandType.doubleClick:
        if (command.button == null) {
          return CommandValidationResult.invalid('Click command requires button');
        }
        break;
        
      case MouseCommandType.scroll:
        if (command.scrollDelta == null) {
          return CommandValidationResult.invalid('Scroll command requires scrollDelta');
        }
        break;
        
      case MouseCommandType.rightClick:
        // Right click doesn't need additional validation
        break;
    }
    
    return CommandValidationResult.valid();
  }
}

class SendCommandParams {
  final MouseCommand command;
  final double? sensitivity;
  
  const SendCommandParams({
    required this.command,
    this.sensitivity,
  });
}

class SendCommandResult {
  final bool isSuccess;
  final String? errorMessage;
  
  const SendCommandResult._({
    required this.isSuccess,
    this.errorMessage,
  });
  
  factory SendCommandResult.success() => const SendCommandResult._(isSuccess: true);
  
  factory SendCommandResult.failure(String message) => SendCommandResult._(
    isSuccess: false,
    errorMessage: message,
  );
}

class CommandValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const CommandValidationResult._({
    required this.isValid,
    this.errorMessage,
  });
  
  factory CommandValidationResult.valid() => const CommandValidationResult._(isValid: true);
  
  factory CommandValidationResult.invalid(String message) => CommandValidationResult._(
    isValid: false,
    errorMessage: message,
  );
}