import 'package:equatable/equatable.dart';

class ConnectionState extends Equatable {
  final String serverAddress;
  final ConnectionStatus status;
  final String? errorMessage;
  final DateTime? lastConnected;
  final int reconnectAttempts;
  
  const ConnectionState({
    required this.serverAddress,
    required this.status,
    this.errorMessage,
    this.lastConnected,
    this.reconnectAttempts = 0,
  });
  
  ConnectionState copyWith({
    String? serverAddress,
    ConnectionStatus? status,
    String? errorMessage,
    DateTime? lastConnected,
    int? reconnectAttempts,
  }) {
    return ConnectionState(
      serverAddress: serverAddress ?? this.serverAddress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastConnected: lastConnected ?? this.lastConnected,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
    );
  }
  
  @override
  List<Object?> get props => [
    serverAddress,
    status,
    errorMessage,
    lastConnected,
    reconnectAttempts,
  ];
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

extension ConnectionStatusExtension on ConnectionStatus {
  bool get isConnected => this == ConnectionStatus.connected;
  bool get isConnecting => this == ConnectionStatus.connecting || this == ConnectionStatus.reconnecting;
  bool get hasError => this == ConnectionStatus.error;
  
  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.error:
        return 'Error';
    }
  }
}