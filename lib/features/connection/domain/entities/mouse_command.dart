import 'package:equatable/equatable.dart';

class MouseCommand extends Equatable {
  final MouseCommandType type;
  final double? x;
  final double? y;
  final double? deltaX;
  final double? deltaY;
  final MouseButton? button;
  final double? scrollDelta;
  final DateTime timestamp;
  
  const MouseCommand({
    required this.type,
    this.x,
    this.y,
    this.deltaX,
    this.deltaY,
    this.button,
    this.scrollDelta,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? const Duration().inMilliseconds as DateTime;
  
  MouseCommand.move({
    required double deltaX,
    required double deltaY,
    DateTime? timestamp,
  }) : this(
    type: MouseCommandType.move,
    deltaX: deltaX,
    deltaY: deltaY,
    timestamp: timestamp,
  );
  
  MouseCommand.click({
    required MouseButton button,
    double? x,
    double? y,
    DateTime? timestamp,
  }) : this(
    type: MouseCommandType.click,
    button: button,
    x: x,
    y: y,
    timestamp: timestamp,
  );
  
  MouseCommand.doubleClick({
    required MouseButton button,
    double? x,
    double? y,
    DateTime? timestamp,
  }) : this(
    type: MouseCommandType.doubleClick,
    button: button,
    x: x,
    y: y,
    timestamp: timestamp,
  );
  
  MouseCommand.scroll({
    required double scrollDelta,
    DateTime? timestamp,
  }) : this(
    type: MouseCommandType.scroll,
    scrollDelta: scrollDelta,
    timestamp: timestamp,
  );
  
  MouseCommand.rightClick({
    double? x,
    double? y,
    DateTime? timestamp,
  }) : this(
    type: MouseCommandType.rightClick,
    x: x,
    y: y,
    timestamp: timestamp,
  );
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'x': x,
      'y': y,
      'deltaX': deltaX,
      'deltaY': deltaY,
      'button': button?.name,
      'scrollDelta': scrollDelta,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  factory MouseCommand.fromJson(Map<String, dynamic> json) {
    return MouseCommand(
      type: MouseCommandType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MouseCommandType.move,
      ),
      x: json['x']?.toDouble(),
      y: json['y']?.toDouble(),
      deltaX: json['deltaX']?.toDouble(),
      deltaY: json['deltaY']?.toDouble(),
      button: json['button'] != null 
        ? MouseButton.values.firstWhere(
            (e) => e.name == json['button'],
            orElse: () => MouseButton.left,
          )
        : null,
      scrollDelta: json['scrollDelta']?.toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }
  
  @override
  List<Object?> get props => [
    type,
    x,
    y,
    deltaX,
    deltaY,
    button,
    scrollDelta,
    timestamp,
  ];
}

enum MouseCommandType {
  move,
  click,
  doubleClick,
  rightClick,
  scroll,
}

enum MouseButton {
  left,
  right,
  middle,
}

extension MouseCommandTypeExtension on MouseCommandType {
  String get displayName {
    switch (this) {
      case MouseCommandType.move:
        return 'Move';
      case MouseCommandType.click:
        return 'Click';
      case MouseCommandType.doubleClick:
        return 'Double Click';
      case MouseCommandType.rightClick:
        return 'Right Click';
      case MouseCommandType.scroll:
        return 'Scroll';
    }
  }
}