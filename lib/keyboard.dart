import 'dart:ffi';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

class KeyboardController {
  // Media control keys
  static void playPause() => _sendKey(VK_MEDIA_PLAY_PAUSE);
  static void stop() => _sendKey(VK_MEDIA_STOP);
  static void nextTrack() => _sendKey(VK_MEDIA_NEXT_TRACK);
  static void previousTrack() => _sendKey(VK_MEDIA_PREV_TRACK);
  static void volumeUp() => _sendKey(VK_VOLUME_UP);
  static void volumeDown() => _sendKey(VK_VOLUME_DOWN);
  static void mute() => _sendKey(VK_VOLUME_MUTE);

  // Browser navigation keys
  static void browserBack() => _sendKeyCombo([VK_BROWSER_BACK]);
  static void browserForward() => _sendKeyCombo([VK_BROWSER_FORWARD]);
  static void browserRefresh() => _sendKeyCombo([VK_F5]);
  static void browserHome() => _sendKeyCombo([VK_BROWSER_HOME]);
  static void browserSearch() => _sendKeyCombo([VK_BROWSER_SEARCH]);
  static void browserFavorites() => _sendKeyCombo([VK_BROWSER_FAVORITES]);

  // Tab navigation
  static void nextTab() => _sendKeyCombo([VK_CONTROL, VK_TAB]);
  static void previousTab() => _sendKeyCombo([VK_CONTROL, VK_SHIFT, VK_TAB]);
  static void closeTab() => _sendKeyCombo([VK_CONTROL, VK_W]);
  static void newTab() => _sendKeyCombo([VK_CONTROL, VK_T]);

  // Window management
  static void altTab() => _sendKeyCombo([VK_MENU, VK_TAB]);
  static void minimizeWindow() => _sendKeyCombo([VK_LWIN, VK_DOWN]);
  static void maximizeWindow() => _sendKeyCombo([VK_LWIN, VK_UP]);
  static void closeWindow() => _sendKeyCombo([VK_MENU, VK_F4]);

  // Fullscreen toggle
  static void toggleFullscreen() => _sendKey(VK_F11);

  // Space bar (for video pause/play)
  static void spaceBar() => _sendKey(VK_SPACE);

  // Arrow keys for seeking
  static void seekForward() => _sendKey(VK_RIGHT);
  static void seekBackward() => _sendKey(VK_LEFT);

  // Send a single key press
  static void _sendKey(int vkCode) {
    final input = calloc<INPUT>();
    try {
      input.ref.type = INPUT_KEYBOARD;
      input.ref.ki.wVk = vkCode;
      input.ref.ki.dwFlags = 0; // Key down
      SendInput(1, input, sizeOf<INPUT>());
      
      // Small delay
      Sleep(50);
      
      input.ref.ki.dwFlags = KEYEVENTF_KEYUP; // Key up
      SendInput(1, input, sizeOf<INPUT>());
    } finally {
      calloc.free(input);
    }
  }

  // Send a key combination (multiple keys pressed together)
  static void _sendKeyCombo(List<int> vkCodes) {
    final inputs = calloc<INPUT>(vkCodes.length * 2); // *2 for key down and up
    try {
      int inputIndex = 0;
      
      // Key down events
      for (int vkCode in vkCodes) {
        inputs[inputIndex].type = INPUT_KEYBOARD;
        inputs[inputIndex].ki.wVk = vkCode;
        inputs[inputIndex].ki.dwFlags = 0; // Key down
        inputIndex++;
      }
      
      // Small delay
      Sleep(50);
      
      // Key up events (in reverse order)
      for (int i = vkCodes.length - 1; i >= 0; i--) {
        inputs[inputIndex].type = INPUT_KEYBOARD;
        inputs[inputIndex].ki.wVk = vkCodes[i];
        inputs[inputIndex].ki.dwFlags = KEYEVENTF_KEYUP; // Key up
        inputIndex++;
      }
      
      SendInput(inputIndex, inputs, sizeOf<INPUT>());
    } finally {
      calloc.free(inputs);
    }
  }

  // Send text input
  static void sendText(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      _sendKey(char);
      Sleep(10); // Small delay between characters
    }
  }
}
