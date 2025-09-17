const webClientHtml = r'''
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Remote Mouse Web</title>
  <style>
    body { font-family: sans-serif; margin:0; background:#fafafa; }
    #status { padding:10px; background:#ddd; }
    #pad { touch-action:none; height:70vh; border:2px dashed #aaa; margin:12px; border-radius:12px; background:#fff; }
    #buttons { display:flex; gap:12px; margin:12px; }
    button { flex:1; padding:16px; font-size:16px; }
  </style>
</head>
<body>
  <div id="status">Disconnected</div>
  <div id="pad"></div>
  <div id="buttons">
    <button id="left">Left Click</button>
    <button id="right">Right Click</button>
    <button id="dbl">Double Click</button>
  </div>
  <script>
    let ws;
    let lastX=null,lastY=null;

    function connect() {
      const proto = location.protocol === "https:" ? "wss" : "ws";
      const wsUrl = proto + "://" + location.host + "/ws?token=CHANGE_ME_1234";
      ws = new WebSocket(wsUrl);
      ws.onopen = ()=> document.getElementById('status').textContent="Connected";
      ws.onclose = ()=> document.getElementById('status').textContent="Disconnected";
      ws.onerror = ()=> document.getElementById('status').textContent="Error";
    }
    connect();

    function send(obj){ if(ws&&ws.readyState===1) ws.send(JSON.stringify(obj)); }

    const pad=document.getElementById('pad');
    pad.addEventListener('pointerdown',e=>{pad.setPointerCapture(e.pointerId);lastX=e.clientX;lastY=e.clientY;});
    pad.addEventListener('pointermove',e=>{
      if(lastX==null)return;
      const dx=e.clientX-lastX,dy=e.clientY-lastY;
      send({type:"move",dx:dx,dy:dy});
      lastX=e.clientX;lastY=e.clientY;
    });
    pad.addEventListener('pointerup',()=>{lastX=lastY=null;});
    document.getElementById('left').onclick=()=>send({type:"click",button:"left"});
    document.getElementById('right').onclick=()=>send({type:"click",button:"right"});
    document.getElementById('dbl').onclick=()=>send({type:"click",button:"left",kind:"double"});
  </script>
</body>
</html>
''';
