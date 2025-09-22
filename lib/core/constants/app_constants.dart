class AppConstants {
  // App Information
  static const String appName = 'Remote Mouse Control';
  static const String appVersion = '2.0.0';
  
  // Network Configuration
  static const String defaultServerAddress = '192.168.1.100:8080';
  static const String websocketPath = '/ws';
  static const String defaultToken = 'CHANGE_ME_1234';
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const int maxReconnectAttempts = 5;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Mouse Configuration
  static const double defaultSensitivity = 2.0;
  static const double minSensitivity = 0.5;
  static const double maxSensitivity = 5.0;
  static const double scrollSensitivity = 1.0;
  
  // Storage Keys
  static const String serverAddressKey = 'server_address';
  static const String mouseSensitivityKey = 'mouse_sensitivity';
  static const String autoConnectKey = 'auto_connect';
  static const String themeKey = 'theme_mode';
  static const String connectionHistoryKey = 'connection_history';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String connectionFailedMessage = 'Failed to connect to server';
  static const String connectionLostMessage = 'Connection lost';
  static const String invalidAddressMessage = 'Invalid server address';
  static const String permissionDeniedMessage = 'Permission denied';
  
  // Success Messages
  static const String connectedMessage = 'Connected successfully';
  static const String disconnectedMessage = 'Disconnected';
  static const String commandSentMessage = 'Command sent';
}