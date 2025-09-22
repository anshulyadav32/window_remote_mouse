import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Server Address
  Future<void> saveServerAddress(String address) async {
    await _prefs.setString(AppConstants.serverAddressKey, address);
  }
  
  String getServerAddress() {
    return _prefs.getString(AppConstants.serverAddressKey) ?? 
           AppConstants.defaultServerAddress;
  }
  
  // Mouse Sensitivity
  Future<void> saveMouseSensitivity(double sensitivity) async {
    await _prefs.setDouble(AppConstants.mouseSensitivityKey, sensitivity);
  }
  
  double getMouseSensitivity() {
    return _prefs.getDouble(AppConstants.mouseSensitivityKey) ?? 
           AppConstants.defaultSensitivity;
  }
  
  // Auto Connect
  Future<void> saveAutoConnect(bool autoConnect) async {
    await _prefs.setBool(AppConstants.autoConnectKey, autoConnect);
  }
  
  bool getAutoConnect() {
    return _prefs.getBool(AppConstants.autoConnectKey) ?? false;
  }
  
  // Theme Mode
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeKey, themeMode);
  }
  
  String getThemeMode() {
    return _prefs.getString(AppConstants.themeKey) ?? 'system';
  }
  
  // Connection History
  Future<void> saveConnectionHistory(List<String> history) async {
    await _prefs.setStringList(AppConstants.connectionHistoryKey, history);
  }
  
  List<String> getConnectionHistory() {
    return _prefs.getStringList(AppConstants.connectionHistoryKey) ?? [];
  }
  
  Future<void> addToConnectionHistory(String address) async {
    final history = getConnectionHistory();
    if (!history.contains(address)) {
      history.insert(0, address);
      // Keep only last 10 connections
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      await saveConnectionHistory(history);
    }
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
  
  // Check if first launch
  bool isFirstLaunch() {
    return !_prefs.containsKey('first_launch_done');
  }
  
  Future<void> setFirstLaunchDone() async {
    await _prefs.setBool('first_launch_done', true);
  }
}