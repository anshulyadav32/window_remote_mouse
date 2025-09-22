/// Server configuration settings for Remote Mouse Control
class ServerConfig {
  // Network settings
  static const String defaultHost = '0.0.0.0';
  static const int defaultPort = 8080;
  static const int maxConnections = 10;
  static const Duration connectionTimeout = Duration(minutes: 30);
  
  // Authentication settings
  static const int tokenLength = 6;
  static const Duration tokenExpiry = Duration(hours: 24);
  static const bool requireAuthentication = true;
  
  // Clipboard settings
  static const bool enableClipboardSync = true;
  static const Duration clipboardCheckInterval = Duration(seconds: 1);
  static const int maxClipboardSize = 1024 * 1024; // 1MB
  
  // WebSocket settings
  static const Duration pingInterval = Duration(seconds: 30);
  static const Duration pongTimeout = Duration(seconds: 10);
  static const int maxMessageSize = 1024 * 1024; // 1MB
  
  // CORS settings
  static const List<String> allowedOrigins = ['*'];
  static const List<String> allowedMethods = ['GET', 'POST', 'OPTIONS'];
  static const List<String> allowedHeaders = ['Content-Type', 'Authorization'];
  
  // Logging settings
  static const bool enableLogging = true;
  static const String logLevel = 'INFO'; // DEBUG, INFO, WARNING, ERROR
  static const bool logToFile = false;
  static const String logFilePath = 'logs/server.log';
  
  // Performance settings
  static const int maxConcurrentRequests = 100;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const bool enableCompression = true;
  
  // Security settings
  static const bool enableRateLimiting = true;
  static const int maxRequestsPerMinute = 1000;
  static const bool enableHttps = false;
  static const String? sslCertPath = null;
  static const String? sslKeyPath = null;
  
  // Feature flags
  static const bool enableMediaControls = true;
  static const bool enableBrowserControls = true;
  static const bool enableWindowControls = true;
  static const bool enableFileTransfer = false;
  
  // Mouse settings
  static const double mouseSensitivity = 1.0;
  static const bool enableMouseAcceleration = true;
  static const int scrollSensitivity = 3;
  
  // Keyboard settings
  static const bool enableKeyboardShortcuts = true;
  static const Duration keyRepeatDelay = Duration(milliseconds: 500);
  static const Duration keyRepeatInterval = Duration(milliseconds: 50);
}

/// Environment-specific configuration
class EnvironmentConfig {
  static bool get isDevelopment => 
      const bool.fromEnvironment('DEVELOPMENT', defaultValue: false);
  
  static bool get isProduction => 
      const bool.fromEnvironment('PRODUCTION', defaultValue: true);
  
  static String get host => 
      const String.fromEnvironment('HOST', defaultValue: ServerConfig.defaultHost);
  
  static int get port => 
      const int.fromEnvironment('PORT', defaultValue: ServerConfig.defaultPort);
  
  static bool get enableLogging => 
      const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: ServerConfig.enableLogging);
}