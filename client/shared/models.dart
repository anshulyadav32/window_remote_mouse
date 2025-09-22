/// Shared models for client-server communication

/// Base message structure for WebSocket communication
abstract class Message {
  final String type;
  final Map<String, dynamic> data;
  final String? id;
  final DateTime timestamp;

  Message({
    required this.type,
    required this.data,
    this.id,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'id': id,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'mouse':
        return MouseMessage.fromJson(json);
      case 'keyboard':
        return KeyboardMessage.fromJson(json);
      case 'media':
        return MediaMessage.fromJson(json);
      case 'browser':
        return BrowserMessage.fromJson(json);
      case 'clipboard':
        return ClipboardMessage.fromJson(json);
      case 'system':
        return SystemMessage.fromJson(json);
      default:
        throw ArgumentError('Unknown message type: ${json['type']}');
    }
  }
}

/// Mouse control messages
class MouseMessage extends Message {
  MouseMessage({
    required String action,
    double? x,
    double? y,
    int? button,
    double? deltaX,
    double? deltaY,
    String? id,
  }) : super(
    type: 'mouse',
    data: {
      'action': action,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (button != null) 'button': button,
      if (deltaX != null) 'deltaX': deltaX,
      if (deltaY != null) 'deltaY': deltaY,
    },
    id: id,
  );

  factory MouseMessage.fromJson(Map<String, dynamic> json) => MouseMessage(
    action: json['data']['action'],
    x: json['data']['x']?.toDouble(),
    y: json['data']['y']?.toDouble(),
    button: json['data']['button'],
    deltaX: json['data']['deltaX']?.toDouble(),
    deltaY: json['data']['deltaY']?.toDouble(),
    id: json['id'],
  );

  String get action => data['action'];
  double? get x => data['x'];
  double? get y => data['y'];
  int? get button => data['button'];
  double? get deltaX => data['deltaX'];
  double? get deltaY => data['deltaY'];
}

/// Keyboard input messages
class KeyboardMessage extends Message {
  KeyboardMessage({
    required String action,
    String? text,
    String? key,
    List<String>? modifiers,
    String? id,
  }) : super(
    type: 'keyboard',
    data: {
      'action': action,
      if (text != null) 'text': text,
      if (key != null) 'key': key,
      if (modifiers != null) 'modifiers': modifiers,
    },
    id: id,
  );

  factory KeyboardMessage.fromJson(Map<String, dynamic> json) => KeyboardMessage(
    action: json['data']['action'],
    text: json['data']['text'],
    key: json['data']['key'],
    modifiers: json['data']['modifiers']?.cast<String>(),
    id: json['id'],
  );

  String get action => data['action'];
  String? get text => data['text'];
  String? get key => data['key'];
  List<String>? get modifiers => data['modifiers']?.cast<String>();
}

/// Media control messages
class MediaMessage extends Message {
  MediaMessage({
    required String action,
    double? volume,
    int? position,
    String? id,
  }) : super(
    type: 'media',
    data: {
      'action': action,
      if (volume != null) 'volume': volume,
      if (position != null) 'position': position,
    },
    id: id,
  );

  factory MediaMessage.fromJson(Map<String, dynamic> json) => MediaMessage(
    action: json['data']['action'],
    volume: json['data']['volume']?.toDouble(),
    position: json['data']['position'],
    id: json['id'],
  );

  String get action => data['action'];
  double? get volume => data['volume'];
  int? get position => data['position'];
}

/// Browser control messages
class BrowserMessage extends Message {
  BrowserMessage({
    required String action,
    String? url,
    String? id,
  }) : super(
    type: 'browser',
    data: {
      'action': action,
      if (url != null) 'url': url,
    },
    id: id,
  );

  factory BrowserMessage.fromJson(Map<String, dynamic> json) => BrowserMessage(
    action: json['data']['action'],
    url: json['data']['url'],
    id: json['id'],
  );

  String get action => data['action'];
  String? get url => data['url'];
}

/// Clipboard synchronization messages
class ClipboardMessage extends Message {
  ClipboardMessage({
    required String action,
    String? content,
    String? id,
  }) : super(
    type: 'clipboard',
    data: {
      'action': action,
      if (content != null) 'content': content,
    },
    id: id,
  );

  factory ClipboardMessage.fromJson(Map<String, dynamic> json) => ClipboardMessage(
    action: json['data']['action'],
    content: json['data']['content'],
    id: json['id'],
  );

  String get action => data['action'];
  String? get content => data['content'];
}

/// System control messages
class SystemMessage extends Message {
  SystemMessage({
    required String action,
    Map<String, dynamic>? params,
    String? id,
  }) : super(
    type: 'system',
    data: {
      'action': action,
      if (params != null) ...params,
    },
    id: id,
  );

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
    action: json['data']['action'],
    params: Map<String, dynamic>.from(json['data'])..remove('action'),
    id: json['id'],
  );

  String get action => data['action'];
}

/// Connection status and authentication
class ConnectionStatus {
  final bool isConnected;
  final String? token;
  final String? serverUrl;
  final String? error;
  final DateTime lastUpdate;

  ConnectionStatus({
    required this.isConnected,
    this.token,
    this.serverUrl,
    this.error,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  ConnectionStatus copyWith({
    bool? isConnected,
    String? token,
    String? serverUrl,
    String? error,
    DateTime? lastUpdate,
  }) => ConnectionStatus(
    isConnected: isConnected ?? this.isConnected,
    token: token ?? this.token,
    serverUrl: serverUrl ?? this.serverUrl,
    error: error ?? this.error,
    lastUpdate: lastUpdate ?? this.lastUpdate,
  );
}

/// Server information
class ServerInfo {
  final String host;
  final int port;
  final String token;
  final bool isRunning;
  final int connectedClients;
  final DateTime startTime;

  ServerInfo({
    required this.host,
    required this.port,
    required this.token,
    required this.isRunning,
    required this.connectedClients,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  String get url => 'http://$host:$port';
  String get wsUrl => 'ws://$host:$port/ws';
}