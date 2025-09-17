import 'dart:convert';
import 'dart:io';
import 'mouse.dart';
import 'web_client.dart';

class RemoteMouseServer {
  final String host;
  final int port;
  final String token;

  HttpServer? _server;

  RemoteMouseServer({this.host='0.0.0.0', this.port=8765, required this.token});

  Future<void> start() async {
    _server = await HttpServer.bind(host, port);
    print('✅ Server running: http://$host:$port');
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
        print('🔗 Client connected');
        socket.listen((data) {
          try {
            final msg = jsonDecode(data as String);
            _handleMessage(msg);
          } catch (e) {
            print('❌ Error parsing message: $e');
          }
        }, onDone: () => print('🔌 Client disconnected'));
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
        MouseController.moveBy(dx, dy);
        break;
        
      case 'click':
        final button = msg['button'] as String? ?? 'left';
        final kind = msg['kind'] as String? ?? 'single';
        
        if (kind == 'double' && button == 'left') {
          MouseController.doubleClickLeft();
        } else if (button == 'left') {
          MouseController.clickLeft(down: true, up: true);
        } else if (button == 'right') {
          MouseController.clickRight(down: true, up: true);
        }
        break;
        
      case 'wheel':
        final delta = _toInt(msg['delta']) ?? 0;
        MouseController.wheel(delta);
        break;
        
      default:
        print('⚠️ Unknown message type: $type');
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
