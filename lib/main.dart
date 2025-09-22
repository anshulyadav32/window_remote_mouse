import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:win32/win32.dart';
import 'server.dart';
import 'android_client.dart';

void main() {
  runApp(RemoteMouseApp());
}

class RemoteMouseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Mouse Server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Platform.isAndroid ? AndroidClientApp() : RemoteMouseHomePage(),
    );
  }
}

class RemoteMouseHomePage extends StatefulWidget {
  @override
  _RemoteMouseHomePageState createState() => _RemoteMouseHomePageState();
}

class _RemoteMouseHomePageState extends State<RemoteMouseHomePage> {
  RemoteMouseServer? _server;
  bool _isRunning = false;
  String _serverUrl = '';
  final String _token = 'SECURE_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
  bool _minimizeOnConnect = true;

  Future<String> _getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      
      // Filter out virtual interfaces
      final realInterfaces = interfaces.where((interface) {
        final name = interface.name.toLowerCase();
        return !name.contains('vethernet') &&
               !name.contains('vmware') &&
               !name.contains('virtualbox') &&
               !name.contains('hyper-v') &&
               !name.contains('loopback') &&
               !name.contains('teredo') &&
               !name.contains('isatap');
      }).toList();
      
      final preferredInterfaces = <String>['wifi', 'wi-fi', 'wireless', 'ethernet', 'wlan', 'eth', 'en'];
      
      // First pass: look for preferred interface names (real interfaces only)
      for (final preferredName in preferredInterfaces) {
        for (final interface in realInterfaces) {
          if (interface.name.toLowerCase().contains(preferredName)) {
            for (final addr in interface.addresses) {
              if (addr.type == InternetAddressType.IPv4 && 
                  !addr.isLoopback && 
                  !addr.isLinkLocal &&
                  _isPrivateIP(addr.address)) {
                print('Found IP on ${interface.name}: ${addr.address}');
                return addr.address;
              }
            }
          }
        }
      }
      
      // Second pass: any valid private IP from real interfaces
      for (final interface in realInterfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              !addr.isLinkLocal &&
              _isPrivateIP(addr.address)) {
            print('Found IP on ${interface.name}: ${addr.address}');
            return addr.address;
          }
        }
      }
      
      // Third pass: any non-loopback IPv4 from real interfaces
      for (final interface in realInterfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            print('Found IP on ${interface.name}: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting local IP: $e');
    }
    return '127.0.0.1';
  }

  bool _isPrivateIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    final first = int.tryParse(parts[0]) ?? 0;
    final second = int.tryParse(parts[1]) ?? 0;
    
    // 192.168.x.x
    if (first == 192 && second == 168) return true;
    // 10.x.x.x
    if (first == 10) return true;
    // 172.16.x.x - 172.31.x.x
    if (first == 172 && second >= 16 && second <= 31) return true;
    
    return false;
  }

  void _minimizeToBackground() {
    try {
      // Get the current window handle
      final hwnd = GetActiveWindow();
      if (hwnd != 0) {
        // Minimize the window
        ShowWindow(hwnd, SW_MINIMIZE);
        print('🪟 Window minimized to background');
      }
    } catch (e) {
      print('❌ Error minimizing window: $e');
    }
  }

  Future<void> _startServer() async {
    try {
      final ip = await _getLocalIP();
      _server = RemoteMouseServer(
        host: '0.0.0.0', 
        port: 8765, 
        token: _token,
        onClientConnected: _minimizeOnConnect ? _minimizeToBackground : null,
      );
      await _server!.start();
      
      setState(() {
        _isRunning = true;
        // Show both IP and custom domain options
        _serverUrl = 'http://$ip:8765 or http://remotemouse.local:8765';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start server: $e')),
      );
    }
  }

  Future<void> _stopServer() async {
    if (_server != null) {
      await _server!.stop();
      setState(() {
        _isRunning = false;
        _serverUrl = '';
      });
    }
  }

  @override
  void dispose() {
    _stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Mouse & Media Control'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _isRunning ? Icons.wifi : Icons.wifi_off,
                        size: 48,
                        color: _isRunning ? Colors.green : Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isRunning ? 'Server Running' : 'Server Stopped',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_isRunning) ...[
                        SizedBox(height: 8),
                        Text(
                          _serverUrl,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopServer : _startServer,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Stop Server' : 'Start Server'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.minimize, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Minimize to background when client connects',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: _minimizeOnConnect,
                        onChanged: (value) {
                          setState(() {
                            _minimizeOnConnect = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_isRunning) ...[
                SizedBox(height: 24),
                Text(
                  'Scan QR Code to Connect:',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _serverUrl,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Instructions:\n'
                  '1. Connect your phone to the same WiFi network\n'
                  '2. Scan the QR code or visit: $_serverUrl\n'
                  '3. Use your phone as a remote control!\n\n'
                  'Features:\n'
                  '🖱️ Mouse Control - Move cursor and click\n'
                  '🎵 Media Control - Play/pause, volume, seek\n'
                  '🌐 Browser Control - Navigation and tabs\n'
                  '🪟 Window Management - Alt+Tab, minimize, etc.\n'
                  '⌨️ Text Input - Send text to computer',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
