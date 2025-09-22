# Client - Frontend Components

This directory contains all frontend components for the Remote Mouse Control application.

## Directory Structure

```
client/
├── web/                    # Web-based client (HTML/CSS/JS)
│   └── web_client.dart    # Web interface implementation
├── mobile/                 # Mobile client applications
│   └── android_client.dart # Android Flutter app
├── shared/                 # Shared components between platforms
├── components/             # Reusable UI components
├── services/              # Client-side services (WebSocket, API)
├── utils/                 # Utility functions and helpers
└── assets/                # Static assets (images, fonts, etc.)
```

## Components

### Web Client (`web/`)
- Browser-based interface accessible via server URL
- Responsive design with modern UI
- Tabbed interface for different control types
- No installation required

### Mobile Client (`mobile/`)
- Native Flutter application for Android
- Touch gesture support with sensitivity adjustment
- Multi-tab interface matching web functionality
- Direct WebSocket connection to server

### Shared (`shared/`)
- Common models and interfaces
- Shared business logic
- Cross-platform utilities

## Features

- **Trackpad Control**: Mouse movement and clicking
- **Media Controls**: Play/pause, volume, seek operations
- **Browser Navigation**: Tab management and shortcuts
- **Text Input**: Send text directly to host computer
- **Clipboard Sync**: Bidirectional clipboard synchronization
- **System Controls**: Window management and shortcuts

## Usage

1. **Web Client**: Navigate to `http://server-ip:port/` in any browser
2. **Mobile Client**: Install and run the Android application
3. **Authentication**: Use the token provided by the server
4. **Connection**: WebSocket connection for real-time control

## Development

- Follow Flutter/Dart conventions for mobile components
- Use modern web standards for browser components
- Maintain consistent UI/UX across platforms
- Implement proper error handling and reconnection logic