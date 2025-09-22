# Server - Backend Services

This directory contains all backend services for the Remote Mouse Control application.

## Directory Structure

```
server/
├── api/                   # API endpoints and routes
├── core/                  # Core server implementation
│   └── server.dart       # Main server class with WebSocket/HTTP handling
├── controllers/           # Request handlers and business logic
│   ├── mouse.dart        # Mouse control operations
│   └── keyboard.dart     # Keyboard input handling
├── services/             # Business services and external integrations
├── models/               # Data models and schemas
├── utils/                # Server utilities and helpers
├── config/               # Configuration files
└── middleware/           # Request middleware (auth, logging, etc.)
```

## Core Components

### Server Core (`core/`)
- **RemoteMouseServer**: Main server class handling HTTP and WebSocket connections
- Token-based authentication system
- Clipboard monitoring and synchronization
- Multi-client connection support

### Controllers (`controllers/`)
- **Mouse Controller**: Handles mouse movement, clicking, scrolling operations
- **Keyboard Controller**: Manages keyboard input, shortcuts, and text input
- Cross-platform compatibility for Windows, macOS, and Linux

### Services (`services/`)
- WebSocket connection management
- Clipboard synchronization service
- System integration services
- Authentication and security services

## Features

### Network Services
- HTTP server for web client hosting
- WebSocket server for real-time communication
- Token-based authentication
- CORS support for web clients

### Control Operations
- **Mouse Control**: Movement, clicking, scrolling, drag operations
- **Keyboard Input**: Text input, key combinations, shortcuts
- **Media Controls**: Volume, playback, media key simulation
- **Browser Control**: Tab management, navigation shortcuts
- **Window Management**: Focus, minimize, maximize operations

### System Integration
- **Clipboard Sync**: Bidirectional clipboard monitoring
- **Multi-platform**: Windows, macOS, Linux support
- **Security**: Token authentication, connection validation
- **Performance**: Efficient WebSocket communication

## Configuration

### Server Settings
- Host and port configuration
- Authentication token management
- Clipboard sync settings
- Connection limits and timeouts

### Security
- Token-based authentication
- Connection validation
- Rate limiting capabilities
- Secure WebSocket connections

## API Endpoints

### HTTP Routes
- `GET /`: Serve web client interface
- `GET /ws`: WebSocket upgrade endpoint
- `POST /auth`: Authentication validation

### WebSocket Commands
- Mouse operations: `mouse_move`, `mouse_click`, `mouse_scroll`
- Keyboard operations: `key_press`, `text_input`, `key_combination`
- Media controls: `media_play`, `media_pause`, `volume_up`
- System operations: `clipboard_sync`, `window_focus`

## Development

- Follow Dart server-side conventions
- Implement proper error handling and logging
- Maintain security best practices
- Use dependency injection for services
- Write comprehensive tests for controllers