import 'dart:ffi';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart'; // <-- this brings in calloc / free

class MouseController {
  static void moveBy(int dx, int dy) {
    final point = calloc<POINT>();
    try {
      GetCursorPos(point);
      final newX = point.ref.x + dx;
      final newY = point.ref.y + dy;
      SetCursorPos(newX, newY);
    } finally {
      calloc.free(point);
    }
  }

  static void moveTo(int x, int y) => SetCursorPos(x, y);

  static void clickLeft({bool down = false, bool up = false}) => _mouseEvent(
      (down ? MOUSEEVENTF_LEFTDOWN : 0) | (up ? MOUSEEVENTF_LEFTUP : 0));

  static void clickRight({bool down = false, bool up = false}) => _mouseEvent(
      (down ? MOUSEEVENTF_RIGHTDOWN : 0) | (up ? MOUSEEVENTF_RIGHTUP : 0));

  static void doubleClickLeft() {
    clickLeft(down: true, up: true);
    clickLeft(down: true, up: true);
  }

  static void wheel(int delta) =>
      _mouseEvent(MOUSEEVENTF_WHEEL, mouseData: delta);

  static void _mouseEvent(int flags, {int mouseData = 0}) {
    final input = calloc<INPUT>();
    try {
      input.ref.type = INPUT_MOUSE;
      input.ref.mi.dwFlags = flags;
      input.ref.mi.mouseData = mouseData;
      SendInput(1, input, sizeOf<INPUT>());
    } finally {
      calloc.free(input);
    }
  }
}
