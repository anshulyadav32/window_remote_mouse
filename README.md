# Remote Mouse Server

A Flutter application that turns your Windows computer into a remote mouse server, allowing you to control your PC from your smartphone via a web interface.

## Features

- 🖱️ **Mouse Control**: Move cursor, left/right click, double-click
- 📱 **Mobile-Friendly**: Web interface optimized for touch devices
- 🔒 **Secure**: Token-based authentication
- 📶 **QR Code**: Easy connection via QR code scanning
- 🌐 **Cross-Platform Client**: Works on any device with a web browser

## Setup

1. **Install Flutter**: Make sure you have Flutter installed on your system
2. **Install Dependencies**: Run lutter pub get in the project directory
3. **Run the App**: Execute lutter run -d windows

## Usage

1. **Start the Server**: Click "Start Server" in the Flutter app
2. **Connect Your Phone**: 
   - Ensure your phone is on the same WiFi network
   - Scan the QR code or visit the displayed URL
3. **Control Your PC**: Use the touchpad area to move the cursor and buttons to click

## Security

The server uses token-based authentication. Each session generates a unique token that must be provided to connect.

## Requirements

- Windows 10/11
- Flutter SDK
- Same WiFi network for PC and mobile device

## Troubleshooting

- **Can't connect**: Ensure both devices are on the same network
- **Firewall issues**: Allow the app through Windows Firewall
- **Port conflicts**: The app uses port 8765 by default
