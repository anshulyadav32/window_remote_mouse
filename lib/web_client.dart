const String webClientHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Remote Mouse</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      color: #333;
    }

    .container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }

    .header {
      text-align: center;
      margin-bottom: 30px;
    }

    .title {
      color: white;
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 10px;
      text-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }

    .status {
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 600;
      display: inline-block;
      margin-bottom: 20px;
    }

    .status-connected {
      background: #4caf50;
      color: white;
    }

    .status-disconnected {
      background: #f44336;
      color: white;
    }

    .nav-tabs {
      display: flex;
      background: rgba(255,255,255,0.1);
      border-radius: 15px;
      padding: 5px;
      margin-bottom: 20px;
      backdrop-filter: blur(10px);
    }

    .nav-tab {
      flex: 1;
      padding: 12px 8px;
      border: none;
      background: transparent;
      color: white;
      border-radius: 10px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-size: 0.9rem;
      font-weight: 500;
    }

    .nav-tab:hover {
      background: rgba(255,255,255,0.1);
    }

    .nav-tab.active {
      background: white;
      color: #333;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .tab-content {
      display: none;
      background: white;
      border-radius: 20px;
      padding: 25px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
      backdrop-filter: blur(10px);
    }

    .tab-content.active {
      display: block;
    }

    .section-title {
      font-size: 1.3rem;
      font-weight: 600;
      margin-bottom: 15px;
      color: #333;
      border-bottom: 2px solid #667eea;
      padding-bottom: 5px;
    }

    .trackpad {
      width: 100%;
      height: 200px;
      background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
      border-radius: 15px;
      margin-bottom: 20px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.1rem;
      color: #666;
      border: 2px solid #e0e0e0;
      transition: all 0.3s ease;
    }

    .trackpad:hover {
      border-color: #667eea;
      box-shadow: 0 5px 15px rgba(102, 126, 234, 0.2);
    }

    .mouse-buttons {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 10px;
      margin-bottom: 20px;
    }

    .control-button {
      padding: 15px;
      border: none;
      border-radius: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      cursor: pointer;
      font-size: 0.9rem;
      font-weight: 500;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }

    .control-button:hover {
      transform: translateY(-2px);
      box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
    }

    .control-button:active {
      transform: translateY(0);
    }

    .media-controls {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 10px;
      margin-bottom: 20px;
    }

    .browser-controls {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      gap: 10px;
      margin-bottom: 20px;
    }

    .window-controls {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
      gap: 10px;
      margin-bottom: 20px;
    }

    .text-input {
      width: 100%;
      padding: 12px;
      border: 2px solid #e0e0e0;
      border-radius: 10px;
      font-size: 1rem;
      margin-bottom: 15px;
      transition: border-color 0.3s ease;
    }

    .text-input:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .text-controls {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
    }

    .clipboard-section {
      margin-bottom: 20px;
    }

    .clipboard-controls {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 10px;
      margin-bottom: 15px;
    }

    .auto-clipboard-section {
      background: #f8f9fa;
      padding: 15px;
      border-radius: 10px;
      margin-top: 15px;
    }

    .icon {
      font-size: 1.2rem;
    }

    @media (max-width: 600px) {
      .container {
        padding: 15px;
      }
      
      .title {
        font-size: 2rem;
      }
      
      .nav-tab {
        font-size: 0.8rem;
        padding: 10px 5px;
      }
      
      .mouse-buttons {
        grid-template-columns: 1fr;
      }
      
      .media-controls,
      .browser-controls,
      .window-controls {
        grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1 class="title">🖱️ Remote Mouse</h1>
      <div id="status" class="status status-disconnected">Connecting...</div>
    </div>

    <div class="nav-tabs">
      <button class="nav-tab active" data-tab="mouse">🖱️ Mouse</button>
      <button class="nav-tab" data-tab="media">🎵 Media</button>
      <button class="nav-tab" data-tab="browser">🌐 Browser</button>
      <button class="nav-tab" data-tab="window">🪟 Window</button>
      <button class="nav-tab" data-tab="text">⌨️ Text</button>
      <button class="nav-tab" data-tab="clipboard">📋 Clipboard</button>
    </div>

    <!-- Mouse Tab -->
    <div id="mouse-tab" class="tab-content active">
      <div class="section-title">Mouse Control</div>
      <div id="pad" class="trackpad">
        Move your finger here to control the mouse
      </div>
      
      <div class="mouse-buttons">
        <button id="left" class="control-button">
          <span class="icon">👆</span>
          <span>Left Click</span>
        </button>
        <button id="right" class="control-button">
          <span class="icon">👆</span>
          <span>Right Click</span>
        </button>
        <button id="dbl" class="control-button">
          <span class="icon">👆👆</span>
          <span>Double Click</span>
        </button>
      </div>

      <div class="auto-clipboard-section">
        <button id="autoClipboard" class="control-button" style="width: 100%;">
          <span class="icon">📋</span>
          <span>Enable Auto Clipboard</span>
        </button>
      </div>
    </div>

    <!-- Media Tab -->
    <div id="media-tab" class="tab-content">
      <div class="section-title">Media Controls</div>
      <div class="media-controls">
        <button id="media_play_pause" class="control-button">
          <span class="icon">⏯️</span>
          <span>Play/Pause</span>
        </button>
        <button id="media_previous" class="control-button">
          <span class="icon">⏮️</span>
          <span>Previous</span>
        </button>
        <button id="media_next" class="control-button">
          <span class="icon">⏭️</span>
          <span>Next</span>
        </button>
        <button id="space" class="control-button">
          <span class="icon">⏸️</span>
          <span>Space</span>
        </button>
        <button id="seek_backward" class="control-button">
          <span class="icon">⏪</span>
          <span>Seek Back</span>
        </button>
        <button id="seek_forward" class="control-button">
          <span class="icon">⏩</span>
          <span>Seek Forward</span>
        </button>
      </div>

      <div class="section-title">Volume Controls</div>
      <div class="media-controls">
        <button id="volume_up" class="control-button">
          <span class="icon">🔊</span>
          <span>Volume Up</span>
        </button>
        <button id="volume_down" class="control-button">
          <span class="icon">🔉</span>
          <span>Volume Down</span>
        </button>
        <button id="volume_mute" class="control-button">
          <span class="icon">🔇</span>
          <span>Mute</span>
        </button>
      </div>

      <div class="auto-clipboard-section">
        <button id="autoClipboardMedia" class="control-button" style="width: 100%;">
          <span class="icon">📋</span>
          <span>Enable Auto Clipboard</span>
        </button>
      </div>
    </div>

    <!-- Browser Tab -->
    <div id="browser-tab" class="tab-content">
      <div class="section-title">Browser Navigation</div>
      <div class="browser-controls">
        <button id="browser_back" class="control-button">
          <span class="icon">⬅️</span>
          <span>Back</span>
        </button>
        <button id="browser_forward" class="control-button">
          <span class="icon">➡️</span>
          <span>Forward</span>
        </button>
        <button id="browser_refresh" class="control-button">
          <span class="icon">🔄</span>
          <span>Refresh</span>
        </button>
        <button id="browser_home" class="control-button">
          <span class="icon">🏠</span>
          <span>Home</span>
        </button>
      </div>

      <div class="section-title">Tab Management</div>
      <div class="browser-controls">
        <button id="new_tab" class="control-button">
          <span class="icon">➕</span>
          <span>New Tab</span>
        </button>
        <button id="close_tab" class="control-button">
          <span class="icon">❌</span>
          <span>Close Tab</span>
        </button>
        <button id="previous_tab" class="control-button">
          <span class="icon">⬅️</span>
          <span>Prev Tab</span>
        </button>
        <button id="next_tab" class="control-button">
          <span class="icon">➡️</span>
          <span>Next Tab</span>
        </button>
      </div>

      <div class="auto-clipboard-section">
        <button id="autoClipboardBrowser" class="control-button" style="width: 100%;">
          <span class="icon">📋</span>
          <span>Enable Auto Clipboard</span>
        </button>
      </div>
    </div>

    <!-- Window Tab -->
    <div id="window-tab" class="tab-content">
      <div class="section-title">Window Management</div>
      <div class="window-controls">
        <button id="alt_tab" class="control-button">
          <span class="icon">🔄</span>
          <span>Alt+Tab</span>
        </button>
        <button id="minimize_window" class="control-button">
          <span class="icon">🔽</span>
          <span>Minimize</span>
        </button>
        <button id="maximize_window" class="control-button">
          <span class="icon">🔼</span>
          <span>Maximize</span>
        </button>
        <button id="toggle_fullscreen" class="control-button">
          <span class="icon">⛶</span>
          <span>Fullscreen</span>
        </button>
      </div>

      <div class="auto-clipboard-section">
        <button id="autoClipboardWindow" class="control-button" style="width: 100%;">
          <span class="icon">📋</span>
          <span>Enable Auto Clipboard</span>
        </button>
      </div>
    </div>

    <!-- Text Tab -->
    <div id="text-tab" class="tab-content">
      <div class="section-title">Text Input</div>
      <input type="text" id="textInput" class="text-input" placeholder="Type text to send...">
      
      <div class="text-controls">
        <button id="sendText" class="control-button" style="flex: 1;">
          <span class="icon">📤</span>
          <span>Send Text</span>
        </button>
        <button id="copyText" class="control-button" style="flex: 1;">
          <span class="icon">📋</span>
          <span>Copy</span>
        </button>
        <button id="sendCopiedText" class="control-button" style="flex: 1;">
          <span class="icon">📋📤</span>
          <span>Send Copied</span>
        </button>
      </div>

      <div class="auto-clipboard-section">
        <button id="autoClipboardText" class="control-button" style="width: 100%;">
          <span class="icon">📋</span>
          <span>Enable Auto Clipboard</span>
        </button>
      </div>
    </div>

    <!-- Clipboard Tab -->
    <div id="clipboard-tab" class="tab-content">
      <div class="section-title">Clipboard Content</div>
      <textarea id="clipboardContent" class="text-input" rows="4" placeholder="Clipboard content will appear here..." readonly></textarea>
      
      <div class="clipboard-controls">
        <button id="getClipboard" class="control-button">
          <span class="icon">📥</span>
          <span>Get Clipboard</span>
        </button>
        <button id="copyToDevice" class="control-button">
          <span class="icon">📤</span>
          <span>Copy to Device</span>
        </button>
        <button id="refreshClipboard" class="control-button">
          <span class="icon">🔄</span>
          <span>Refresh</span>
        </button>
      </div>

      <div class="section-title">Set Device Clipboard</div>
      <textarea id="clipboardInput" class="text-input" rows="3" placeholder="Type text to send to device clipboard..."></textarea>
      <button id="setClipboard" class="control-button" style="width: 100%;">
        <span class="icon">📋</span>
        <span>Set Device Clipboard</span>
      </button>
    </div>
  </div>

  <script>
    let ws;
    let lastX = null, lastY = null;
    let autoClipboardEnabled = false;

    function connect() {
      const proto = location.protocol === "https:" ? "wss" : "ws";
      const wsUrl = proto + "://" + location.host + "/ws?token=CHANGE_ME_1234";
      ws = new WebSocket(wsUrl);
      
      ws.onopen = () => {
        document.getElementById('status').textContent = "Connected";
        document.getElementById('status').className = "status status-connected";
      };
      
      ws.onclose = () => {
        document.getElementById('status').textContent = "Disconnected";
        document.getElementById('status').className = "status status-disconnected";
      };
      
      ws.onerror = () => {
        document.getElementById('status').textContent = "Connection Error";
        document.getElementById('status').className = "status status-disconnected";
      };

      // Handle incoming WebSocket messages
      ws.onmessage = function(event) {
        const data = JSON.parse(event.data);
        if (data.type === 'clipboard_content') {
          document.getElementById('clipboardContent').value = data.content;
        }
      };
    }
    connect();

    function send(obj) { 
      if (ws && ws.readyState === 1) {
        ws.send(JSON.stringify(obj));
      }
    }

    // Tab switching
    document.querySelectorAll('.nav-tab').forEach(tab => {
      tab.addEventListener('click', () => {
        // Remove active class from all tabs and content
        document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        
        // Add active class to clicked tab and corresponding content
        tab.classList.add('active');
        const tabName = tab.dataset.tab;
        document.getElementById(tabName + '-tab').classList.add('active');
      });
    });

    // Mouse controls
    const pad = document.getElementById('pad');
    pad.addEventListener('pointerdown', e => {
      pad.setPointerCapture(e.pointerId);
      lastX = e.clientX;
      lastY = e.clientY;
    });
    
    pad.addEventListener('pointermove', e => {
      if (lastX == null) return;
      const dx = e.clientX - lastX;
      const dy = e.clientY - lastY;
      send({type: "move", dx: dx, dy: dy});
      lastX = e.clientX;
      lastY = e.clientY;
    });
    
    pad.addEventListener('pointerup', () => {
      lastX = lastY = null;
    });

    // Mouse buttons
    document.getElementById('left').onclick = () => send({type: "click", button: "left"});
    document.getElementById('right').onclick = () => send({type: "click", button: "right"});
    document.getElementById('dbl').onclick = () => send({type: "click", button: "left", kind: "double"});

    // Media controls
    document.getElementById('media_play_pause').onclick = () => send({type: "media_play_pause"});
    document.getElementById('media_next').onclick = () => send({type: "media_next"});
    document.getElementById('media_previous').onclick = () => send({type: "media_previous"});
    document.getElementById('volume_up').onclick = () => send({type: "volume_up"});
    document.getElementById('volume_down').onclick = () => send({type: "volume_down"});
    document.getElementById('volume_mute').onclick = () => send({type: "volume_mute"});
    document.getElementById('space').onclick = () => send({type: "space"});
    document.getElementById('seek_forward').onclick = () => send({type: "seek_forward"});
    document.getElementById('seek_backward').onclick = () => send({type: "seek_backward"});

    // Browser controls
    document.getElementById('browser_back').onclick = () => send({type: "browser_back"});
    document.getElementById('browser_forward').onclick = () => send({type: "browser_forward"});
    document.getElementById('browser_refresh').onclick = () => send({type: "browser_refresh"});
    document.getElementById('browser_home').onclick = () => send({type: "browser_home"});
    document.getElementById('next_tab').onclick = () => send({type: "next_tab"});
    document.getElementById('previous_tab').onclick = () => send({type: "previous_tab"});
    document.getElementById('close_tab').onclick = () => send({type: "close_tab"});
    document.getElementById('new_tab').onclick = () => send({type: "new_tab"});

    // Window controls
    document.getElementById('alt_tab').onclick = () => send({type: "alt_tab"});
    document.getElementById('minimize_window').onclick = () => send({type: "minimize_window"});
    document.getElementById('maximize_window').onclick = () => send({type: "maximize_window"});
    document.getElementById('toggle_fullscreen').onclick = () => send({type: "toggle_fullscreen"});

    // Text input
    document.getElementById('sendText').onclick = () => {
      const text = document.getElementById('textInput').value;
      if (text.trim()) {
        send({type: "send_text", text: text});
        document.getElementById('textInput').value = '';
      }
    };

    // Allow Enter key to send text
    document.getElementById('textInput').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        document.getElementById('sendText').click();
      }
    });

    // Copy text button handler
    document.getElementById('copyText').onclick = () => {
      const textInput = document.getElementById('textInput');
      const text = textInput.value;
      if (text.trim()) {
        // Copy to browser clipboard
        navigator.clipboard.writeText(text).then(() => {
          // Visual feedback
          const button = document.getElementById('copyText');
          const originalText = button.innerHTML;
          button.innerHTML = '<span class="icon">✓</span><span>Copied!</span>';
          button.style.background = 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)';
          
          setTimeout(() => {
            button.innerHTML = originalText;
            button.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
          }, 1000);
        }).catch(err => {
          console.error('Failed to copy text: ', err);
        });
      }
    };

    // Send copied text button handler
    document.getElementById('sendCopiedText').onclick = () => {
      navigator.clipboard.readText().then(text => {
        if (text.trim()) {
          // Send the copied text to the device
          send({type: "send_text", text: text});
          
          // Visual feedback
          const button = document.getElementById('sendCopiedText');
          const originalText = button.innerHTML;
          button.innerHTML = '<span class="icon">✓</span><span>Sent!</span>';
          button.style.background = 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)';
          
          setTimeout(() => {
            button.innerHTML = originalText;
            button.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
          }, 1000);
        } else {
          // Show error if clipboard is empty
          const button = document.getElementById('sendCopiedText');
          const originalText = button.innerHTML;
          button.innerHTML = '<span class="icon">❌</span><span>Empty!</span>';
          button.style.background = 'linear-gradient(135deg, #f44336 0%, #d32f2f 100%)';
          
          setTimeout(() => {
            button.innerHTML = originalText;
            button.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
          }, 1000);
        }
      }).catch(err => {
        console.error('Failed to read clipboard: ', err);
        // Show error feedback
        const button = document.getElementById('sendCopiedText');
        const originalText = button.innerHTML;
        button.innerHTML = '<span class="icon">❌</span><span>Error!</span>';
        button.style.background = 'linear-gradient(135deg, #f44336 0%, #d32f2f 100%)';
        
        setTimeout(() => {
          button.innerHTML = originalText;
          button.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
        }, 1000);
      });
    };

    // Clipboard controls
    document.getElementById('getClipboard').onclick = () => {
      send({type: "get_clipboard"});
    };

    document.getElementById('setClipboard').onclick = () => {
      const text = document.getElementById('clipboardInput').value;
      if (text.trim()) {
        send({type: "set_clipboard", text: text});
        document.getElementById('clipboardInput').value = '';
      }
    };

    document.getElementById('copyToDevice').onclick = () => {
      const text = document.getElementById('clipboardContent').value;
      if (text.trim()) {
        send({type: "set_clipboard", text: text});
      }
    };

    document.getElementById('refreshClipboard').onclick = () => {
      send({type: "get_clipboard"});
    };

    // Auto clipboard toggle function
    function toggleAutoClipboard(buttonId) {
      autoClipboardEnabled = !autoClipboardEnabled;
      const button = document.getElementById(buttonId);
      
      if (autoClipboardEnabled) {
        button.innerHTML = '<span class="icon">📋</span><span>Disable Auto Clipboard</span>';
        button.style.background = 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)';
        send({type: "enable_auto_clipboard"});
      } else {
        button.innerHTML = '<span class="icon">📋</span><span>Enable Auto Clipboard</span>';
        button.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
        send({type: "disable_auto_clipboard"});
      }
      
      // Update all other auto clipboard buttons to match the state
      const allAutoClipboardButtons = ['autoClipboard', 'autoClipboardMedia', 'autoClipboardBrowser', 'autoClipboardWindow', 'autoClipboardText'];
      allAutoClipboardButtons.forEach(id => {
        if (id !== buttonId) {
          const otherButton = document.getElementById(id);
          if (otherButton) {
            if (autoClipboardEnabled) {
              otherButton.innerHTML = '<span class="icon">📋</span><span>Disable Auto Clipboard</span>';
              otherButton.style.background = 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)';
            } else {
              otherButton.innerHTML = '<span class="icon">📋</span><span>Enable Auto Clipboard</span>';
              otherButton.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
            }
          }
        }
      });
    }
    
    // Auto clipboard button event handlers
    document.getElementById('autoClipboard').onclick = () => toggleAutoClipboard('autoClipboard');
    document.getElementById('autoClipboardMedia').onclick = () => toggleAutoClipboard('autoClipboardMedia');
    document.getElementById('autoClipboardBrowser').onclick = () => toggleAutoClipboard('autoClipboardBrowser');
    document.getElementById('autoClipboardWindow').onclick = () => toggleAutoClipboard('autoClipboardWindow');
    document.getElementById('autoClipboardText').onclick = () => toggleAutoClipboard('autoClipboardText');
  </script>
</body>
</html>
''';
