const webClientHtml = r'''
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Remote Mouse & Media Control</title>
  <style>
    * { box-sizing: border-box; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
      margin: 0; 
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }
    
    .navbar {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(10px);
      padding: 12px 16px;
      box-shadow: 0 2px 20px rgba(0,0,0,0.1);
      position: sticky;
      top: 0;
      z-index: 100;
    }
    
    .nav-tabs {
      display: flex;
      gap: 8px;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
    }
    
    .nav-tab {
      background: transparent;
      border: 2px solid #e0e0e0;
      border-radius: 25px;
      padding: 8px 16px;
      font-size: 14px;
      font-weight: 500;
      color: #666;
      cursor: pointer;
      transition: all 0.3s ease;
      white-space: nowrap;
      min-width: fit-content;
    }
    
    .nav-tab.active {
      background: #667eea;
      border-color: #667eea;
      color: white;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
    }
    
    .nav-tab:hover:not(.active) {
      border-color: #667eea;
      color: #667eea;
    }
    
    .content {
      padding: 16px;
    }
    
    .tab-content {
      display: none;
    }
    
    .tab-content.active {
      display: block;
    }
    
    #status { 
      padding: 12px 16px; 
      background: rgba(255, 255, 255, 0.9);
      border-radius: 12px;
      margin-bottom: 16px;
      text-align: center;
      font-weight: 500;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .status-connected { color: #4caf50; }
    .status-disconnected { color: #f44336; }
    
    #pad { 
      touch-action: none; 
      height: 50vh; 
      border: 2px dashed #ccc; 
      margin: 16px 0; 
      border-radius: 16px; 
      background: rgba(255, 255, 255, 0.9);
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #999;
      font-size: 18px;
    }
    
    .control-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 12px;
      margin: 16px 0;
    }
    
    .control-section {
      background: rgba(255, 255, 255, 0.9);
      border-radius: 16px;
      padding: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }
    
    .section-title {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin-bottom: 12px;
      text-align: center;
    }
    
    button { 
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      border-radius: 12px;
      padding: 12px 8px;
      font-size: 12px;
      font-weight: 500;
      color: white;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
      min-height: 44px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
    }
    
    button:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
    }
    
    button:active {
      transform: translateY(0);
    }
    
    .media-controls {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
    }
    
    .volume-controls {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
    }
    
    .browser-controls {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
    }
    
    .tab-controls {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
    }
    
    .window-controls {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
    }
    
    .mouse-controls {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
    }
    
    .text-input {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 12px;
      font-size: 16px;
      margin-bottom: 12px;
      background: rgba(255, 255, 255, 0.9);
    }
    
    .text-input:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    
    .icon {
      font-size: 18px;
    }
    
    @media (max-width: 480px) {
      .control-grid {
        grid-template-columns: 1fr;
      }
      
      .media-controls,
      .volume-controls,
      .browser-controls,
      .tab-controls,
      .window-controls,
      .mouse-controls {
        grid-template-columns: repeat(2, 1fr);
      }
    }
  </style>
</head>
<body>
  <div class="navbar">
    <div class="nav-tabs">
      <button class="nav-tab active" data-tab="mouse">🖱️ Mouse</button>
      <button class="nav-tab" data-tab="media">🎵 Media</button>
      <button class="nav-tab" data-tab="browser">🌐 Browser</button>
      <button class="nav-tab" data-tab="window">🪟 Window</button>
      <button class="nav-tab" data-tab="text">⌨️ Text</button>
    </div>
  </div>

  <div class="content">
    <div id="status" class="status-disconnected">Disconnected</div>
    
    <!-- Mouse Tab -->
    <div id="mouse-tab" class="tab-content active">
      <div id="pad">Touch and drag to move mouse</div>
      <div class="control-section">
        <div class="section-title">Mouse Controls</div>
        <div class="mouse-controls">
          <button id="left">
            <span class="icon">👆</span>
            <span>Left Click</span>
          </button>
          <button id="right">
            <span class="icon">👆</span>
            <span>Right Click</span>
          </button>
          <button id="dbl">
            <span class="icon">👆👆</span>
            <span>Double Click</span>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Media Tab -->
    <div id="media-tab" class="tab-content">
      <div class="control-section">
        <div class="section-title">Media Controls</div>
        <div class="media-controls">
          <button id="media_previous">
            <span class="icon">⏮️</span>
            <span>Previous</span>
          </button>
          <button id="media_play_pause">
            <span class="icon">⏯️</span>
            <span>Play/Pause</span>
          </button>
          <button id="media_next">
            <span class="icon">⏭️</span>
            <span>Next</span>
          </button>
        </div>
      </div>
      
      <div class="control-section">
        <div class="section-title">Volume Controls</div>
        <div class="volume-controls">
          <button id="volume_down">
            <span class="icon">🔉</span>
            <span>Volume Down</span>
          </button>
          <button id="volume_mute">
            <span class="icon">🔇</span>
            <span>Mute</span>
          </button>
          <button id="volume_up">
            <span class="icon">🔊</span>
            <span>Volume Up</span>
          </button>
        </div>
      </div>
      
      <div class="control-section">
        <div class="section-title">Seek Controls</div>
        <div class="media-controls">
          <button id="seek_backward">
            <span class="icon">⏪</span>
            <span>Seek Back</span>
          </button>
          <button id="space">
            <span class="icon">⏸️</span>
            <span>Space</span>
          </button>
          <button id="seek_forward">
            <span class="icon">⏩</span>
            <span>Seek Forward</span>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Browser Tab -->
    <div id="browser-tab" class="tab-content">
      <div class="control-section">
        <div class="section-title">Browser Navigation</div>
        <div class="browser-controls">
          <button id="browser_back">
            <span class="icon">⬅️</span>
            <span>Back</span>
          </button>
          <button id="browser_forward">
            <span class="icon">➡️</span>
            <span>Forward</span>
          </button>
          <button id="browser_refresh">
            <span class="icon">🔄</span>
            <span>Refresh</span>
          </button>
          <button id="browser_home">
            <span class="icon">🏠</span>
            <span>Home</span>
          </button>
        </div>
      </div>
      
      <div class="control-section">
        <div class="section-title">Tab Management</div>
        <div class="tab-controls">
          <button id="previous_tab">
            <span class="icon">⬅️</span>
            <span>Prev Tab</span>
          </button>
          <button id="next_tab">
            <span class="icon">➡️</span>
            <span>Next Tab</span>
          </button>
          <button id="new_tab">
            <span class="icon">➕</span>
            <span>New Tab</span>
          </button>
          <button id="close_tab">
            <span class="icon">❌</span>
            <span>Close Tab</span>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Window Tab -->
    <div id="window-tab" class="tab-content">
      <div class="control-section">
        <div class="section-title">Window Management</div>
        <div class="window-controls">
          <button id="alt_tab">
            <span class="icon">🔄</span>
            <span>Alt+Tab</span>
          </button>
          <button id="toggle_fullscreen">
            <span class="icon">⛶</span>
            <span>Fullscreen</span>
          </button>
          <button id="minimize_window">
            <span class="icon">➖</span>
            <span>Minimize</span>
          </button>
          <button id="maximize_window">
            <span class="icon">➕</span>
            <span>Maximize</span>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Text Tab -->
    <div id="text-tab" class="tab-content">
      <div class="control-section">
        <div class="section-title">Text Input</div>
        <input type="text" id="textInput" class="text-input" placeholder="Type text to send...">
        <button id="sendText" style="width: 100%;">
          <span class="icon">📤</span>
          <span>Send Text</span>
        </button>
      </div>
    </div>
  </div>

  <script>
    let ws;
    let lastX = null, lastY = null;

    function connect() {
      const proto = location.protocol === "https:" ? "wss" : "ws";
      const wsUrl = proto + "://" + location.host + "/ws?token=CHANGE_ME_1234";
      ws = new WebSocket(wsUrl);
      
      ws.onopen = () => {
        document.getElementById('status').textContent = "Connected";
        document.getElementById('status').className = "status-connected";
      };
      
      ws.onclose = () => {
        document.getElementById('status').textContent = "Disconnected";
        document.getElementById('status').className = "status-disconnected";
      };
      
      ws.onerror = () => {
        document.getElementById('status').textContent = "Connection Error";
        document.getElementById('status').className = "status-disconnected";
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
    document.getElementById('media_stop').onclick = () => send({type: "media_stop"});
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
    document.getElementById('browser_search').onclick = () => send({type: "browser_search"});
    document.getElementById('browser_favorites').onclick = () => send({type: "browser_favorites"});
    document.getElementById('next_tab').onclick = () => send({type: "next_tab"});
    document.getElementById('previous_tab').onclick = () => send({type: "previous_tab"});
    document.getElementById('close_tab').onclick = () => send({type: "close_tab"});
    document.getElementById('new_tab').onclick = () => send({type: "new_tab"});

    // Window controls
    document.getElementById('alt_tab').onclick = () => send({type: "alt_tab"});
    document.getElementById('minimize_window').onclick = () => send({type: "minimize_window"});
    document.getElementById('maximize_window').onclick = () => send({type: "maximize_window"});
    document.getElementById('close_window').onclick = () => send({type: "close_window"});
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
  </script>
</body>
</html>
''';
