import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'mouse.dart';
import 'keyboard.dart';
import 'web_client.dart';

class RemoteMouseServer {
  final String host;
  final int port;
  final String token;
  final Function()? onClientConnected;

  HttpServer? _server;
  WebSocket? _currentSocket;
  String _lastClipboardContent = '';
  bool _autoClipboardEnabled = true; // Auto clipboard enabled by default

  RemoteMouseServer({this.host='0.0.0.0', this.port=8765, required this.token, this.onClientConnected});

  Future<void> start() async {
    _server = await HttpServer.bind(host, port);
    print('✅ Server running: http://$host:$port');
    
    // Start clipboard monitoring
    _startClipboardMonitoring();
    
    _server!.listen((HttpRequest request) async {
      final path = request.uri.path;

      if (path == '/ws' && WebSocketTransformer.isUpgradeRequest(request)) {
        final qsToken = request.uri.queryParameters['token'];
        if (qsToken != token) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write('Invalid token');
          await request.response.close();
          return;
        }
        final socket = await WebSocketTransformer.upgrade(request);
        _currentSocket = socket;
        print('🔗 Client connected');
        
        // Call the callback when client connects
        onClientConnected?.call();
        
        // Send current clipboard content to newly connected client
        _sendClipboardToClient();
        
        socket.listen((data) {
          try {
            final msg = jsonDecode(data as String);
            _handleMessage(msg);
          } catch (e) {
            print('❌ Error parsing message: $e');
          }
        }, onDone: () {
          print('🔌 Client disconnected');
          _currentSocket = null;
        });
      } else if (path == '/' || path == '/index.html') {
        request.response.headers.contentType = ContentType.html;
        request.response.write(webClientHtml.replaceAll('CHANGE_ME_1234', token));
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
        await request.response.close();
      }
    });
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    
    switch (type) {
      case 'move':
        final dx = _toInt(msg['dx']) ?? 0;
        final dy = _toInt(msg['dy']) ?? 0;
        try {
          MouseController.moveBy(dx, dy);
        } catch (e) {
          print('❌ Mouse move error: $e');
        }
        break;
        
      case 'click':
        final button = msg['button'] as String? ?? 'left';
        final kind = msg['kind'] as String? ?? 'single';
        
        try {
          if (kind == 'double' && button == 'left') {
            MouseController.doubleClickLeft();
          } else if (button == 'left') {
            MouseController.clickLeft(down: true, up: true);
          } else if (button == 'right') {
            MouseController.clickRight(down: true, up: true);
          }
          print('✅ Mouse click: $button $kind');
        } catch (e) {
          print('❌ Mouse click error: $e');
        }
        break;
        
      case 'wheel':
        final delta = _toInt(msg['delta']) ?? 0;
        MouseController.wheel(delta);
        break;
        
      // Media controls
      case 'media_play_pause':
        try {
          KeyboardController.playPause();
          print('✅ Media: play/pause');
        } catch (e) {
          print('❌ Media play/pause error: $e');
        }
        break;
      case 'media_stop':
        try {
          KeyboardController.stop();
          print('✅ Media: stop');
        } catch (e) {
          print('❌ Media stop error: $e');
        }
        break;
      case 'media_next':
        try {
          KeyboardController.nextTrack();
          print('✅ Media: next track');
        } catch (e) {
          print('❌ Media next error: $e');
        }
        break;
      case 'media_previous':
        try {
          KeyboardController.previousTrack();
          print('✅ Media: previous track');
        } catch (e) {
          print('❌ Media previous error: $e');
        }
        break;
      case 'volume_up':
        try {
          KeyboardController.volumeUp();
          print('✅ Volume: up');
        } catch (e) {
          print('❌ Volume up error: $e');
        }
        break;
      case 'volume_down':
        try {
          KeyboardController.volumeDown();
          print('✅ Volume: down');
        } catch (e) {
          print('❌ Volume down error: $e');
        }
        break;
      case 'volume_mute':
        try {
          KeyboardController.mute();
          print('✅ Volume: mute');
        } catch (e) {
          print('❌ Volume mute error: $e');
        }
        break;
      case 'space':
        try {
          KeyboardController.spaceBar();
          print('✅ Space bar');
        } catch (e) {
          print('❌ Space bar error: $e');
        }
        break;
      case 'seek_forward':
        try {
          KeyboardController.seekForward();
          print('✅ Seek: forward');
        } catch (e) {
          print('❌ Seek forward error: $e');
        }
        break;
      case 'seek_backward':
        try {
          KeyboardController.seekBackward();
          print('✅ Seek: backward');
        } catch (e) {
          print('❌ Seek backward error: $e');
        }
        break;
        
      // Browser controls
      case 'browser_back':
        KeyboardController.browserBack();
        break;
      case 'browser_forward':
        KeyboardController.browserForward();
        break;
      case 'browser_refresh':
        KeyboardController.browserRefresh();
        break;
      case 'browser_home':
        KeyboardController.browserHome();
        break;
      case 'browser_search':
        KeyboardController.browserSearch();
        break;
      case 'browser_favorites':
        KeyboardController.browserFavorites();
        break;
      case 'next_tab':
        KeyboardController.nextTab();
        break;
      case 'previous_tab':
        KeyboardController.previousTab();
        break;
      case 'close_tab':
        KeyboardController.closeTab();
        break;
      case 'new_tab':
        KeyboardController.newTab();
        break;
        
      // Window management
      case 'alt_tab':
        KeyboardController.altTab();
        break;
      case 'minimize_window':
        KeyboardController.minimizeWindow();
        break;
      case 'maximize_window':
        KeyboardController.maximizeWindow();
        break;
      case 'close_window':
        KeyboardController.closeWindow();
        break;
      case 'toggle_fullscreen':
        KeyboardController.toggleFullscreen();
        break;
        
      // Text input
      case 'send_text':
        final text = msg['text'] as String? ?? '';
        KeyboardController.sendText(text);
        break;
        
      // Clipboard operations
      case 'set_clipboard':
        final text = msg['text'] as String? ?? '';
        _setClipboard(text);
        break;
        
      case 'get_clipboard':
        _sendClipboardToClient();
        break;
        
      case 'enable_auto_clipboard':
        _autoClipboardEnabled = true;
        print('📋 Auto clipboard enabled');
        break;
        
      case 'disable_auto_clipboard':
        _autoClipboardEnabled = false;
        print('📋 Auto clipboard disabled');
        break;
        
      default:
        print('⚠️ Unknown message type: $type');
    }
  }

  // Clipboard monitoring and management methods
  void _startClipboardMonitoring() {
    // Monitor clipboard changes every 500ms
    Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (!_autoClipboardEnabled) return; // Only monitor if auto clipboard is enabled
      
      try {
        final currentContent = await FlutterClipboard.paste();
        if (currentContent != _lastClipboardContent && currentContent.isNotEmpty) {
          _lastClipboardContent = currentContent;
          _sendClipboardToClient();
          print('📋 Clipboard changed: ${currentContent.length > 50 ? currentContent.substring(0, 50) + '...' : currentContent}');
        }
      } catch (e) {
        // Ignore clipboard access errors
      }
    });
  }

  void _sendClipboardToClient() {
    if (_currentSocket != null && _lastClipboardContent.isNotEmpty) {
      try {
        final message = jsonEncode({
          'type': 'clipboard_content',
          'content': _lastClipboardContent,
        });
        _currentSocket!.add(message);
      } catch (e) {
        print('❌ Error sending clipboard to client: $e');
      }
    }
  }

  void _setClipboard(String text) async {
    try {
      await FlutterClipboard.copy(text);
      _lastClipboardContent = text;
      print('📋 Clipboard set: ${text.length > 50 ? text.substring(0, 50) + '...' : text}');
    } catch (e) {
      print('❌ Error setting clipboard: $e');
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    print('🛑 Server stopped');
  }
}
