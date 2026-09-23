import os, base64

def build_html():
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
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<style>
  html, body {{ margin:0; padding:0; overflow:hidden; background:transparent; width:100%; height:100%; }}
  canvas {{ display:block; width:100%; height:100%; }}
  #debug {{ position:absolute; top:0; left:0; color:red; background:rgba(0,0,0,0.85);
            font-size:11px; font-weight:bold; font-family:monospace; z-index:9999;
            width:100%; overflow:auto; pointer-events:none; padding:4px; display:none; }}
</style>
</head>
<body>
<div id="debug"></div>
<script>
var _dbg = document.getElementById('debug');
window.onerror = function(msg, src, line) {{
  if (_dbg) {{ _dbg.style.display = 'block'; _dbg.innerHTML += 'ERR L'+line+': '+msg+'<br>'; }}
}};
</script>
<script>{three_js}</script>
<script>{gltf_js}</script>
<script>
var scene, camera, renderer, modelRoot, skeleton;
var bones = {{}};
var restRot = {{}};
var idleClock = 0;
var ready = false;

/*
 * VERIFIED bone hierarchy from GLB parse:
 * 
 * Bone.020 (wrist)
 *   Bone.016 (palm) - parent of all fingers
 *     Bone.012 -> Bone -> Bone.001 -> Bone.002       = INDEX
 *     Bone.013 -> Bone.003 -> Bone.004 -> Bone.005   = MIDDLE
 *     Bone.014 -> Bone.006 -> Bone.007 -> Bone.008   = RING
 *     Bone.015 -> Bone.009 -> Bone.010 -> Bone.011   = PINKY
 *     Bone.021 -> Bone.017 -> Bone.018 -> Bone.019   = THUMB
 *
 * Curl axis = X (negative = curl inward)
 * Thumb spread axis = Z on Bone.021
 */

var CHAINS = {{
  index:  ['Bone.012', 'Bone',     'Bone.001', 'Bone.002'],
  middle: ['Bone.013', 'Bone.003', 'Bone.004', 'Bone.005'],
  ring:   ['Bone.014', 'Bone.006', 'Bone.007', 'Bone.008'],
  pinky:  ['Bone.015', 'Bone.009', 'Bone.010', 'Bone.011'],
  thumb:  ['Bone.021', 'Bone.017', 'Bone.018', 'Bone.019']
}};

// Each bone in a 4-bone chain gets this fraction of total curl
var CURL_FRAC = [0.25, 0.30, 0.25, 0.20];
// Total radians when fully curled (negative X = fingers curl inward)
var MAX_CURL = -2.0;

// Current & target pose
var cur = {{ idx:0, mid:0, ring:0, pink:0, thCurl:0, thSpread:0, spread:0, tilt:0 }};
var tgt = {{ idx:0, mid:0, ring:0, pink:0, thCurl:0, thSpread:0, spread:0, tilt:0 }};

// ASL-inspired shapes: curl 0=straight, 1=fully curled
var shapes = {{
  idle: {{ f:[0.1,0.1,0.1,0.1], tc:0.1, ts:0.5, sp:0, ti:0 }},
  a: {{ f:[1,1,1,1],         tc:0.3, ts:0.8, sp:0,    ti:0 }},
  b: {{ f:[0,0,0,0],         tc:1,   ts:0,   sp:0.2,  ti:0 }},
  c: {{ f:[0.4,0.4,0.4,0.4], tc:0.4, ts:0.4, sp:0,    ti:0 }},
  d: {{ f:[0,1,1,1],         tc:0.7, ts:0.3, sp:0,    ti:0 }},
  e: {{ f:[0.9,0.9,0.9,0.9], tc:0.9, ts:0,   sp:0,    ti:0 }},
  f: {{ f:[0.5,0,0,0],       tc:0.5, ts:0.4, sp:0,    ti:0 }},
  g: {{ f:[0,1,1,1],         tc:0.2, ts:0.8, sp:0,    ti:0 }},
  h: {{ f:[0,0,1,1],         tc:1,   ts:0,   sp:0,    ti:0 }},
  i: {{ f:[1,1,1,0],         tc:1,   ts:0,   sp:0,    ti:0 }},
  j: {{ f:[1,1,1,0],         tc:1,   ts:0,   sp:0,    ti:0.3 }},
  k: {{ f:[0,0,1,1],         tc:0.3, ts:0.5, sp:0.5,  ti:0 }},
  l: {{ f:[0,1,1,1],         tc:0,   ts:1,   sp:0,    ti:0 }},
  m: {{ f:[1,1,1,0.7],       tc:0.8, ts:0,   sp:0,    ti:0 }},
  n: {{ f:[1,1,0.3,0.3],     tc:0.8, ts:0,   sp:0,    ti:0 }},
  o: {{ f:[0.5,0.5,0.5,0.5], tc:0.5, ts:0.3, sp:0,    ti:0 }},
  p: {{ f:[0,0,1,1],         tc:0.3, ts:0.5, sp:0.5,  ti:2.6 }},
  q: {{ f:[0,1,1,1],         tc:0.2, ts:0.8, sp:0,    ti:2.6 }},
  r: {{ f:[0.1,0.1,1,1],     tc:1,   ts:0,   sp:-0.5, ti:0 }},
  s: {{ f:[1,1,1,1],         tc:1,   ts:0,   sp:0,    ti:0 }},
  t: {{ f:[1,1,1,1],         tc:0.5, ts:0.2, sp:0,    ti:0 }},
  u: {{ f:[0,0,1,1],         tc:1,   ts:0,   sp:0,    ti:0 }},
  v: {{ f:[0,0,1,1],         tc:1,   ts:0,   sp:0.7,  ti:0 }},
  w: {{ f:[0,0,0,1],         tc:1,   ts:0,   sp:0.5,  ti:0 }},
  x: {{ f:[0.5,1,1,1],       tc:0.6, ts:0.2, sp:0,    ti:0 }},
  y: {{ f:[1,1,1,0],         tc:0,   ts:1,   sp:0,    ti:0 }},
  z: {{ f:[0,1,1,1],         tc:0.6, ts:0.3, sp:0,    ti:0 }}
}};

var accentMap = {{'á':'a','é':'e','í':'i','ó':'o','ú':'u','ü':'u','ñ':'n'}};
function strip(s) {{ return s.split('').map(function(c){{ return accentMap[c]||c; }}).join(''); }}

function init() {{
  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(35, window.innerWidth/window.innerHeight || 1, 0.01, 1000);
  renderer = new THREE.WebGLRenderer({{ antialias:true, alpha:true }});
  renderer.setSize(window.innerWidth || 300, window.innerHeight || 300);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  document.body.appendChild(renderer.domElement);

  scene.add(new THREE.AmbientLight(0xffffff, 0.8));
  var d = new THREE.DirectionalLight(0xffffff, 0.9); d.position.set(2.5, 3, 4); scene.add(d);
  var r = new THREE.DirectionalLight(0x88bbff, 0.35); r.position.set(-3, -1, 2); scene.add(r);

  new THREE.GLTFLoader().load('{glb_uri}', function(gltf) {{
    modelRoot = new THREE.Group();
    modelRoot.add(gltf.scene);
    scene.add(modelRoot);

    gltf.scene.traverse(function(obj) {{
      if (obj.isSkinnedMesh && !skeleton) skeleton = obj.skeleton;
      if (obj.isBone) {{
        bones[obj.name] = obj;
        obj.matrixAutoUpdate = true;
      }}
    }});

    // Save rest pose
    for (var n in bones) {{
      var b = bones[n];
      restRot[n] = {{ x:b.rotation.x, y:b.rotation.y, z:b.rotation.z }};
    }}

    // Center & scale
    var box = new THREE.Box3().setFromObject(gltf.scene);
    var sz = new THREE.Vector3(); box.getSize(sz);
    var ct = new THREE.Vector3(); box.getCenter(ct);
    var mx = Math.max(sz.x, sz.y, sz.z) || 1;
    var sc = 2.0 / mx;
    gltf.scene.scale.setScalar(sc);
    gltf.scene.position.set(-ct.x*sc, -ct.y*sc, -ct.z*sc);

    // Camera looking at palm/fingers side, shifted slightly left
    camera.position.set(-0.3, 0, 4);
    camera.lookAt(0, 0, 0);
    // Rotate to show fingers facing camera
    modelRoot.rotation.set(0.1, -0.5, 0);

    setTarget('idle');
    for (var k in tgt) cur[k] = tgt[k];
    ready = true;

  }}, undefined, function(err) {{ window.onerror('GLB: ' + err); }});
}}

function setTarget(letter) {{
  var s = shapes[letter];
  if (!s) return;
  tgt = {{
    idx: s.f[0], mid: s.f[1], ring: s.f[2], pink: s.f[3],
    thCurl: s.tc, thSpread: s.ts, spread: s.sp || 0, tilt: s.ti || 0
  }};
}}

function curlChain(chainNames, amount) {{
  for (var i = 0; i < chainNames.length; i++) {{
    var bone = bones[chainNames[i]];
    var rest = restRot[chainNames[i]];
    if (!bone || !rest) continue;
    // Curl on X axis (negative = inward)
    var delta = amount * MAX_CURL * CURL_FRAC[i];
    bone.rotation.x = rest.x + delta;
    bone.rotation.y = rest.y;
    bone.rotation.z = rest.z;
  }}
}}

function applyPose(bob) {{
  if (!ready) return;
  var c = cur;

  // Curl each finger
  curlChain(CHAINS.index,  c.idx);
  curlChain(CHAINS.middle, c.mid);
  curlChain(CHAINS.ring,   c.ring);
  curlChain(CHAINS.pinky,  c.pink);
  curlChain(CHAINS.thumb,  c.thCurl);

  // Thumb spread (Z axis on root bone Bone.021)
  var tb = bones['Bone.021'];
  var tr = restRot['Bone.021'];
  if (tb && tr) {{
    tb.rotation.z = tr.z + c.thSpread * 0.8;
  }}

  // Finger spread (index & middle, Z axis on root bones)
  var ir = bones['Bone.012'];
  var mr = bones['Bone.013'];
  if (ir && restRot['Bone.012']) {{
    ir.rotation.z = restRot['Bone.012'].z + c.spread * 0.3;
  }}
  if (mr && restRot['Bone.013']) {{
    mr.rotation.z = restRot['Bone.013'].z - c.spread * 0.3;
  }}

  // Wrist tilt & idle bob
  if (modelRoot) {{
    modelRoot.position.y = bob;
    if (c.tilt !== 0) modelRoot.rotation.z = c.tilt;
    else modelRoot.rotation.z = 0;
  }}
}}

function animate() {{
  requestAnimationFrame(animate);

  // Lerp current toward target
  for (var k in cur) cur[k] += (tgt[k] - cur[k]) * 0.18;

  idleClock += 0.02;
  var bob = spellTimer ? 0 : Math.sin(idleClock) * 0.04;

  applyPose(bob);

  // CRITICAL: update skeleton so mesh deforms
  if (skeleton) skeleton.update();

  renderer.render(scene, camera);
}}

// Spell word letter by letter
var spellTimer = null;

function spellWord(text) {{
  if (spellTimer) {{ clearInterval(spellTimer); spellTimer = null; }}
  var clean = strip((text || '').toLowerCase());
  var letters = clean.split('').filter(function(ch) {{ return shapes[ch] !== undefined; }});
  if (letters.length === 0) {{ setTarget('idle'); return; }}

  var i = 0;
  setTarget(letters[0]);
  i = 1;
  spellTimer = setInterval(function() {{
    if (i >= letters.length) {{
      clearInterval(spellTimer);
      spellTimer = null;
      setTimeout(function() {{ setTarget('idle'); }}, 400);
      return;
    }}
    setTarget(letters[i]);
    i++;
  }}, 500);
}}
window.spellWord = spellWord;

window.addEventListener('resize', function() {{
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}});

init();
animate();
</script>
</body>
</html>
"""
    with open(os.path.join(base_dir, 'hand3d.html'), 'w', encoding='utf-8') as f:
        f.write(html)
    print("Final production HTML generated.")

build_html()
