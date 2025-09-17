import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Project File Structure', () {
    final projectRoot = Directory.current.path;

    test('pubspec.yaml exists', () {
      expect(File('$projectRoot/pubspec.yaml').existsSync(), isTrue);
    });

    test('lib/main.dart exists', () {
      final file = File('$projectRoot/lib/main.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('RemoteMouseApp'), isTrue);
    });

    test('lib/server.dart exists', () {
      final file = File('$projectRoot/lib/server.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('RemoteMouseServer'), isTrue);
    });

    test('lib/mouse.dart exists', () {
      final file = File('$projectRoot/lib/mouse.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('MouseController'), isTrue);
    });

    test('lib/web_client.dart exists', () {
      final file = File('$projectRoot/lib/web_client.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('<!doctype html>'), isTrue);
    });
  });
}