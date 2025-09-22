import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';
import 'dart:convert';

class AndroidClientApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Mouse Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RemoteMouseScreen(),
    );
  }
}

class RemoteMouseScreen extends StatefulWidget {
  @override
  _RemoteMouseScreenState createState() => _RemoteMouseScreenState();
}

class _RemoteMouseScreenState extends State<RemoteMouseScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  WebSocket? _webSocket;
  bool _isConnected = false;
  String _serverAddress = '';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  // Touch tracking for trackpad
  Offset? _lastPanPosition;
  double _sensitivity = 2.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _addressController.text = '192.168.1.100:8080'; // Default server address
  }

  @override
  void dispose() {
    _tabController.dispose();
    _webSocket?.close();
    _addressController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_addressController.text.isEmpty) return;
    
    try {
      final uri = Uri.parse('ws://${_addressController.text}/ws?token=CHANGE_ME_1234');
      _webSocket = await WebSocket.connect(uri.toString());
      
      setState(() {
        _isConnected = true;
        _serverAddress = _addressController.text;
      });
      
      _webSocket!.listen(
        (data) {
          // Handle incoming messages if needed
          print('Received: $data');
        },
        onDone: () {
          setState(() {
            _isConnected = false;
          });
          _showMessage('Connection closed');
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
          });
          _showMessage('Connection error: $error');
        },
      );
      
      _showMessage('Connected to $_serverAddress');
    } catch (e) {
      _showMessage('Failed to connect: $e');
    }
  }

  void _disconnect() {
    _webSocket?.close();
    setState(() {
      _isConnected = false;
    });
    _showMessage('Disconnected');
  }

  void _sendCommand(Map<String, dynamic> command) {
    if (_webSocket != null && _isConnected) {
      try {
        _webSocket!.add(jsonEncode(command));
      } catch (e) {
        _showMessage('Failed to send command: $e');
      }
    } else {
      _showMessage('Not connected to server');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Mouse Control'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.mouse), text: 'Mouse'),
            Tab(icon: Icon(Icons.music_note), text: 'Media'),
            Tab(icon: Icon(Icons.web), text: 'Browser'),
            Tab(icon: Icon(Icons.window), text: 'Window'),
            Tab(icon: Icon(Icons.keyboard), text: 'Text'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildConnectionPanel(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMouseTab(),
                _buildMediaTab(),
                _buildBrowserTab(),
                _buildWindowTab(),
                _buildTextTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      color: _isConnected ? Colors.green[100] : Colors.red[100],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Server Address (IP:Port)',
                    hintText: '192.168.1.100:8080',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  enabled: !_isConnected,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : _connect,
                child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: _isConnected ? Colors.green[800] : Colors.red[800],
              ),
              SizedBox(width: 8),
              Text(
                _isConnected ? 'Connected to $_serverAddress' : 'Disconnected',
                style: TextStyle(
                  color: _isConnected ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMouseTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Sensitivity slider
          Row(
            children: [
              Text('Sensitivity: '),
              Expanded(
                child: Slider(
                  value: _sensitivity,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: _sensitivity.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _sensitivity = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            flex: 3,
            child: _buildTrackpad(),
          ),
          SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: _buildMouseButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackpad() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onPanStart: (details) {
          _lastPanPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_lastPanPosition != null && _isConnected) {
            final dx = (details.localPosition.dx - _lastPanPosition!.dx) * _sensitivity;
            final dy = (details.localPosition.dy - _lastPanPosition!.dy) * _sensitivity;
            
            _sendCommand({
              'type': 'move',
              'dx': dx.round(),
              'dy': dy.round(),
            });
            
            _lastPanPosition = details.localPosition;
          }
        },
        onPanEnd: (details) {
          _lastPanPosition = null;
        },
        onTap: () {
          // Single tap for left click
          _sendCommand({'type': 'click', 'button': 'left'});
          HapticFeedback.lightImpact();
        },
        onLongPress: () {
          // Long press for right click
          _sendCommand({'type': 'click', 'button': 'right'});
          HapticFeedback.mediumImpact();
        },
        onDoubleTap: () {
          // Double tap for double click
          _sendCommand({
            'type': 'click',
            'button': 'left',
            'kind': 'double'
          });
          HapticFeedback.heavyImpact();
        },
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent && _isConnected) {
              // Handle scroll wheel events
              final scrollDelta = pointerSignal.scrollDelta.dy;
              _sendCommand({
                'type': 'wheel',
                'delta': (-scrollDelta * 120).round(), // Convert to Windows wheel delta
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 48, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    'Touch and drag to move mouse',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap: Left click • Long press: Right click',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    'Double tap: Double click • Scroll: Wheel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMouseButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _sendCommand({'type': 'click', 'button': 'left'});
              HapticFeedback.lightImpact();
            },
            icon: Icon(Icons.touch_app),
            label: Text('Left Click'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _sendCommand({'type': 'click', 'button': 'right'});
              HapticFeedback.lightImpact();
            },
            icon: Icon(Icons.touch_app),
            label: Text('Right Click'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _sendCommand({
                'type': 'click',
                'button': 'left',
                'kind': 'double'
              });
              HapticFeedback.mediumImpact();
            },
            icon: Icon(Icons.double_arrow),
            label: Text('Double Click'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildControlSection('Media Controls', [
            _buildControlButton(Icons.skip_previous, 'Previous', () =>
                _sendCommand({'type': 'media_previous'})),
            _buildControlButton(Icons.play_arrow, 'Play/Pause', () =>
                _sendCommand({'type': 'media_play_pause'})),
            _buildControlButton(Icons.skip_next, 'Next', () =>
                _sendCommand({'type': 'media_next'})),
          ]),
          SizedBox(height: 16),
          _buildControlSection('Volume Controls', [
            _buildControlButton(Icons.volume_down, 'Volume Down', () =>
                _sendCommand({'type': 'volume_down'})),
            _buildControlButton(Icons.volume_mute, 'Mute', () =>
                _sendCommand({'type': 'volume_mute'})),
            _buildControlButton(Icons.volume_up, 'Volume Up', () =>
                _sendCommand({'type': 'volume_up'})),
          ]),
          SizedBox(height: 16),
          _buildControlSection('Seek Controls', [
            _buildControlButton(Icons.fast_rewind, 'Seek Backward', () =>
                _sendCommand({'type': 'seek_backward'})),
            _buildControlButton(Icons.space_bar, 'Space', () =>
                _sendCommand({'type': 'space'})),
            _buildControlButton(Icons.fast_forward, 'Seek Forward', () =>
                _sendCommand({'type': 'seek_forward'})),
          ]),
        ],
      ),
    );
  }

  Widget _buildBrowserTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildControlSection('Browser Navigation', [
            _buildControlButton(Icons.arrow_back, 'Back', () =>
                _sendCommand({'type': 'browser_back'})),
            _buildControlButton(Icons.arrow_forward, 'Forward', () =>
                _sendCommand({'type': 'browser_forward'})),
            _buildControlButton(Icons.refresh, 'Refresh', () =>
                _sendCommand({'type': 'browser_refresh'})),
            _buildControlButton(Icons.home, 'Home', () =>
                _sendCommand({'type': 'browser_home'})),
          ]),
          SizedBox(height: 16),
          _buildControlSection('Tab Controls', [
            _buildControlButton(Icons.tab, 'Previous Tab', () =>
                _sendCommand({'type': 'previous_tab'})),
            _buildControlButton(Icons.add, 'New Tab', () =>
                _sendCommand({'type': 'new_tab'})),
            _buildControlButton(Icons.tab_unselected, 'Next Tab', () =>
                _sendCommand({'type': 'next_tab'})),
            _buildControlButton(Icons.close, 'Close Tab', () =>
                _sendCommand({'type': 'close_tab'})),
          ]),
        ],
      ),
    );
  }

  Widget _buildWindowTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildControlSection('Window Controls', [
            _buildControlButton(Icons.alt_route, 'Alt+Tab', () =>
                _sendCommand({'type': 'alt_tab'})),
            _buildControlButton(Icons.minimize, 'Minimize', () =>
                _sendCommand({'type': 'minimize_window'})),
            _buildControlButton(Icons.crop_square, 'Maximize', () =>
                _sendCommand({'type': 'maximize_window'})),
            _buildControlButton(Icons.fullscreen, 'Fullscreen', () =>
                _sendCommand({'type': 'toggle_fullscreen'})),
          ]),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Text to send',
              border: OutlineInputBorder(),
              hintText: 'Type text to send to computer...',
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _sendCommand({
                  'type': 'send_text',
                  'text': _textController.text,
                });
                _textController.clear();
              }
            },
            icon: Icon(Icons.send),
            label: Text('Send Text'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: buttons,
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}