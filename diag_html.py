import os, base64, json

def build_diagnostic():
    base_dir = 'connectvoice_app/assets/html'
    
    with open(os.path.join(base_dir, 'three.min.js'), 'r', encoding='utf-8') as f:
        three_js = f.read()
    with open(os.path.join(base_dir, 'GLTFLoader.js'), 'r', encoding='utf-8') as f:
        gltf_js = f.read()
    with open(os.path.join(base_dir, 'hand.glb'), 'rb') as f:
        glb_data = f.read()
    glb_b64 = base64.b64encode(glb_data).decode('utf-8')
    glb_uri = f"data:application/octet-stream;base64,{glb_b64}"
    
    html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  html,body {{ margin:0; padding:0; background:#111; color:#0f0; font:11px monospace; }}
  #info {{ position:absolute; top:0; left:0; z-index:999; background:rgba(0,0,0,0.9); padding:8px; max-height:50%; overflow:auto; width:100%; }}
  canvas {{ display:block; }}
  .btn {{ display:inline-block; margin:2px; padding:4px 8px; background:#333; color:#fff; cursor:pointer; border:1px solid #555; font-size:10px; }}
  .btn:hover {{ background:#555; }}
</style>
</head><body>
<div id="info">Loading...</div>
<script>{three_js}</script>
<script>{gltf_js}</script>
<script>
let scene, camera, renderer, skeleton;
let allBones = [];
let restRot = {{}};
let bonesByName = {{}};

function init() {{
  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(35, window.innerWidth/window.innerHeight, 0.01, 1000);
  renderer = new THREE.WebGLRenderer({{ antialias:true, alpha:true }});
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.appendChild(renderer.domElement);
  scene.add(new THREE.AmbientLight(0xffffff, 0.8));
  var d = new THREE.DirectionalLight(0xffffff, 0.9); d.position.set(2,3,4); scene.add(d);

  new THREE.GLTFLoader().load('{glb_uri}', function(gltf) {{
    scene.add(gltf.scene);
    
    gltf.scene.traverse(function(o) {{
      if (o.isSkinnedMesh && !skeleton) skeleton = o.skeleton;
      if (o.isBone) {{
        allBones.push(o);
        bonesByName[o.name] = o;
        o.matrixAutoUpdate = true;
      }}
    }});
    
    allBones.forEach(function(b) {{
      restRot[b.name] = {{x:b.rotation.x, y:b.rotation.y, z:b.rotation.z}};
    }});

    // Center & scale
    var box = new THREE.Box3().setFromObject(gltf.scene);
    var sz = new THREE.Vector3(); box.getSize(sz);
    var ct = new THREE.Vector3(); box.getCenter(ct);
    var mx = Math.max(sz.x,sz.y,sz.z)||1;
    var sc = 2.0/mx;
    gltf.scene.scale.setScalar(sc);
    gltf.scene.position.set(-ct.x*sc,-ct.y*sc,-ct.z*sc);
    camera.position.set(0,0,4);
    camera.lookAt(0,0,0);
    
    // Build hierarchy info
    var html = '<b>BONE HIERARCHY</b><br>';
    
    // Find root bones (bones whose parent is not a bone)
    var roots = allBones.filter(function(b) {{ return !b.parent || !b.parent.isBone; }});
    html += 'Root bones: ' + roots.map(function(r){{return r.name;}}).join(', ') + '<br><br>';
    
    // Recursively print tree
    function printTree(bone, depth) {{
      var indent = '';
      for(var i=0;i<depth;i++) indent += '&nbsp;&nbsp;';
      var childBones = allBones.filter(function(b){{ return b.parent === bone; }});
      var worldPos = new THREE.Vector3();
      bone.getWorldPosition(worldPos);
      html += indent + '<b>' + bone.name + '</b> children:' + childBones.length + 
              ' pos:(' + worldPos.x.toFixed(2) + ',' + worldPos.y.toFixed(2) + ',' + worldPos.z.toFixed(2) + ')' +
              ' rot:(' + bone.rotation.x.toFixed(2) + ',' + bone.rotation.y.toFixed(2) + ',' + bone.rotation.z.toFixed(2) + ')' +
              '<br>';
      childBones.forEach(function(c) {{ printTree(c, depth+1); }});
    }}
    roots.forEach(function(r) {{ printTree(r, 0); }});
    
    // Detect chains (leaf to root paths)
    html += '<br><b>FINGER CHAINS (leaf to root)</b><br>';
    var leaves = allBones.filter(function(b) {{
      return allBones.filter(function(c){{ return c.parent === b; }}).length === 0;
    }});
    
    var chains = [];
    leaves.forEach(function(leaf) {{
      var chain = [];
      var cur = leaf;
      while(cur && cur.isBone) {{
        chain.unshift(cur.name);
        cur = cur.parent;
      }}
      chains.push(chain);
    }});
    
    chains.forEach(function(ch, i) {{
      html += 'Chain ' + i + ': [' + ch.join(' → ') + ']<br>';
    }});
    
    // Add curl test buttons for each chain
    html += '<br><b>TEST EACH CHAIN</b><br>';
    chains.forEach(function(ch, i) {{
      html += '<span class="btn" onclick="testChain('+i+')">Curl chain '+i+'</span> ';
    }});
    html += '<br><span class="btn" onclick="resetAll()">RESET ALL</span>';
    
    window._chains = chains;
    document.getElementById('info').innerHTML = html;
    
    animate();
  }});
}}

function testChain(idx) {{
  resetAll();
  var chain = window._chains[idx];
  chain.forEach(function(name) {{
    var b = bonesByName[name];
    var r = restRot[name];
    if(b && r) {{
      // Try all axes
      b.rotation.x = r.x + 0.8;
      b.rotation.z = r.z + 0.3;
    }}
  }});
}}

function resetAll() {{
  allBones.forEach(function(b) {{
    var r = restRot[b.name];
    if(r) {{ b.rotation.x = r.x; b.rotation.y = r.y; b.rotation.z = r.z; }}
  }});
}}

function animate() {{
  requestAnimationFrame(animate);
  if(skeleton) skeleton.update();
  renderer.render(scene, camera);
}}

init();
</script></body></html>"""
    
    with open(os.path.join(base_dir, 'diag.html'), 'w', encoding='utf-8') as f:
        f.write(html)
    print("Diagnostic HTML created: connectvoice_app/assets/html/diag.html")

build_diagnostic()
