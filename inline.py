import os
import base64

def inline_assets():
    base_dir = 'connectvoice_app/assets/html'
    
    with open(os.path.join(base_dir, 'three.min.js'), 'r', encoding='utf-8') as f:
        three_js = f.read()
    with open(os.path.join(base_dir, 'GLTFLoader.js'), 'r', encoding='utf-8') as f:
        gltf_js = f.read()
        
    with open(os.path.join(base_dir, 'hand.glb'), 'rb') as f:
        glb_data = f.read()
    glb_b64 = base64.b64encode(glb_data).decode('utf-8')
    glb_uri = f"data:application/octet-stream;base64,{glb_b64}"
    
    with open(os.path.join(base_dir, 'hand3d.html'), 'r', encoding='utf-8') as f:
        html = f.read()
        
    # Inject debug overlay
    debug_div = '<div id="debug" style="position:absolute; top:0; left:0; color:white; background:rgba(0,0,0,0.5); font-size:12px; z-index:9999; max-height:100%; overflow:auto;"></div>'
    debug_script = '''
<script>
window.logMsg = function(msg) {
  var d = document.getElementById('debug');
  if(d) {
     d.innerHTML += msg + '<br>';
     d.scrollTop = d.scrollHeight;
  }
};
window.onerror = function(msg, src, lineno, colno, err) {
  window.logMsg('ERR: ' + msg);
};
</script>
'''
    html = html.replace('<body>', f'<body>\n{debug_div}\n{debug_script}')
    
    # Inject logs into JS functions
    html = html.replace('function spellWord(text){', "function spellWord(text){ window.logMsg('spellWord called: ' + text);")
    html = html.replace('function init(){', "function init(){ window.logMsg('init started');")
    html = html.replace('ready = true;', "ready = true; window.logMsg('ready=true, bones:' + Object.keys(bones).length);")
    
    # Check if requestAnimationFrame is running
    html = html.replace('let idleClock = 0;', 'let idleClock = 0; let frameCount = 0;')
    html = html.replace('requestAnimationFrame(animate);', '')
    html = html.replace('function animate(){', "function animate(){ frameCount++; if(frameCount % 60 === 0) { /* window.logMsg('frames: ' + frameCount); */ }")
    html = html.replace('init();', 'init(); setInterval(animate, 30);')
    
    # Replace scripts
    html = html.replace('<script src="three.min.js"></script>', f'<script>\n{three_js}\n</script>')
    html = html.replace('<script src="GLTFLoader.js"></script>', f'<script>\n{gltf_js}\n</script>')
    
    # Replace glb load
    html = html.replace("'hand.glb'", f"'{glb_uri}'")
    
    with open(os.path.join(base_dir, 'hand3d.html'), 'w', encoding='utf-8') as f:
        f.write(html)
        
    print("Inlining with debug complete.")

inline_assets()
