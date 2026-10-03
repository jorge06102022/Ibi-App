import json
import random

words_100 = [
    "HOLA", "ADIOS", "GRACIAS", "PORFAVOR", "PERDON", "SI", "NO", "BIEN", "MAL", "MAS",
    "MENOS", "YO", "TU", "EL", "ELLA", "NOSOTROS", "ELLOS", "MI", "TUYO", "SUYO",
    "MAMA", "PAPA", "HIJO", "HIJA", "HERMANO", "HERMANA", "ABUELO", "ABUELA", "TIO", "TIA",
    "AMIGO", "AMIGA", "PROFESOR", "ESTUDIANTE", "HOMBRE", "MUJER", "NINO", "NINA", "BEBE", "FAMILIA",
    "CASA", "ESCUELA", "TRABAJO", "CALLE", "CIUDAD", "PAIS", "MUNDO", "AGUA", "COMIDA", "BEBIDA",
    "PAN", "CARNE", "FRUTA", "VERDURA", "LECHE", "CAFE", "TE", "DESAYUNO", "ALMUERZO", "CENA",
    "DIA", "NOCHE", "MANANA", "TARDE", "HOY", "AYER", "SEMANA", "MES", "ANO", "COMO ESTAS",
    "LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO", "HORA", "MINUTO", "TIEMPO",
    "ROJO", "AZUL", "VERDE", "AMARILLO", "BLANCO", "NEGRO", "PERRO", "GATO", "ANIMAL", "FELIZ",
    "TRISTE", "ENOJADO", "CANSADO", "ENFERMO", "SANO", "FUERTE", "DEBIL", "GRANDE", "PEQUENO", "AMOR"
]

def relaxed_fingers():
    return [[0, 0.2, 0.2] for _ in range(5)]

def closed_fingers():
    return [[0, 1.5, 1.5] for _ in range(5)]

poses = {}
random.seed(123)

for w in words_100:
    poses[w] = {
        'rArm': [random.uniform(-0.2, 1.0), random.uniform(-0.5, 0.5), random.uniform(0.5, 1.5)],
        'rForeArm': [-random.uniform(0.5, 2.5), 0, 0],
        'rHand': [0, 0, 0],
        'lArm': [random.uniform(-0.2, 1.0), random.uniform(-0.5, 0.5), random.uniform(-1.5, -0.5)],
        'lForeArm': [-random.uniform(0.5, 2.5), 0, 0],
        'lHand': [0, 0, 0],
        'rFingers': relaxed_fingers(),
        'lFingers': relaxed_fingers()
    }

# Ajustes manuales para algunas comunes
poses['HOLA'] = {'rArm': [0, 0, 1.5], 'rForeArm': [-0.2, 0, 0], 'rHand': [0, 0, 0], 'lArm': [0,0,0], 'lForeArm': [0,0,0], 'lHand': [0,0,0], 'rFingers': relaxed_fingers(), 'lFingers': relaxed_fingers()}
poses['COMO ESTAS'] = {'rArm': [0.5, 0, 0.5], 'rForeArm': [-1.0, 0, 0], 'rHand': [0, 0, 0], 'lArm': [0.5, 0, -0.5], 'lForeArm': [-1.0, 0, 0], 'lHand': [0,0,0], 'rFingers': relaxed_fingers(), 'lFingers': relaxed_fingers()}

poses['IDLE'] = {
    'rArm': [0, 0, 0.2], 'rForeArm': [0, 0, 0], 'rHand': [0, 0, 0],
    'lArm': [0, 0, -0.2], 'lForeArm': [0, 0, 0], 'lHand': [0, 0, 0],
    'spine': [0,0,0], 'head': [0,0,0],
    'rFingers': relaxed_fingers(), 'lFingers': relaxed_fingers()
}

database = {
    'words': poses
}

json_db = json.dumps(database)

html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<style>
  html,body{{margin:0;padding:0;overflow:hidden;background:#1a1a1a;width:100%;height:100%}}
  canvas{{display:block;width:100%;height:100%}}
  #debug_text {{position:absolute;bottom:30px;left:50%;transform:translateX(-50%);color:#fff;background:rgba(0,0,0,0.7);padding:15px 25px;border-radius:20px;font-family:'Segoe UI', sans-serif;z-index:9999;display:none;font-size:20px;font-weight:600;letter-spacing:1px;box-shadow: 0 4px 15px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.1);}}
  #ai_indicator {{position:absolute;top:20px;right:20px;color:#0f0;font-family:monospace;font-size:14px;background:rgba(0,255,0,0.1);padding:5px 10px;border-radius:5px;border:1px solid #0f0;display:flex;align-items:center;gap:8px;}}
  .dot {{width:8px;height:8px;background:#0f0;border-radius:50%;animation: blink 1s infinite;}}
  @keyframes blink {{ 0%, 100% {{opacity: 1;}} 50% {{opacity: 0.3;}} }}
</style>
</head>
<body>
<div id="ai_indicator"><div class="dot"></div> LSC Dictionary Mode</div>
<div id="debug_text"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
(function(){{
'use strict';

var scene, camera, renderer, clock;
var avatarModel = null;
var bones = {{}};
var baseRotations = {{}};

function setupScene() {{
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x111111);
  scene.fog = new THREE.Fog(0x111111, 2, 6);

  var w = window.innerWidth || 300;
  var h = window.innerHeight || 300;
  camera = new THREE.PerspectiveCamera(35, w/h, 0.1, 100);
  
  renderer = new THREE.WebGLRenderer({{antialias:true, powerPreference:"high-performance"}});
  renderer.setSize(w, h);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.outputEncoding = THREE.sRGBEncoding;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  document.body.appendChild(renderer.domElement);

  var hemiLight = new THREE.HemisphereLight(0xffffff, 0x444455, 0.4);
  hemiLight.position.set(0, 10, 0);
  scene.add(hemiLight);

  var mainLight = new THREE.DirectionalLight(0xffffff, 1.2);
  mainLight.position.set(2, 5, 4);
  mainLight.castShadow = true;
  scene.add(mainLight);
  
  var backLight = new THREE.DirectionalLight(0x4488ff, 1.5);
  backLight.position.set(-3, 4, -4);
  scene.add(backLight);

  var fillLight = new THREE.DirectionalLight(0xffaa88, 0.5);
  fillLight.position.set(3, 1, 2);
  scene.add(fillLight);

  clock = new THREE.Clock();
}}

function buildThreeJSAvatar() {{
  avatarModel = new THREE.Group();
  
  const skinMat = new THREE.MeshPhysicalMaterial({{ color: 0xe0ac88, roughness: 0.4, metalness: 0.1, clearcoat: 0.1 }});
  const suitMat = new THREE.MeshPhysicalMaterial({{ color: 0x202022, roughness: 0.7, metalness: 0.3, clearcoat: 0.2 }});
  const jointMat = new THREE.MeshPhysicalMaterial({{ color: 0x404040, roughness: 0.5, metalness: 0.8 }});

  function createBoneMesh(radius, length, mat) {{
      const geo = new THREE.CylinderGeometry(radius*0.8, radius, length, 32);
      geo.translate(0, -length/2, 0);
      const mesh = new THREE.Mesh(geo, mat);
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      return mesh;
  }}

  function createJoint(radius) {{
      const geo = new THREE.SphereGeometry(radius, 32, 32);
      const mesh = new THREE.Mesh(geo, jointMat);
      mesh.castShadow = true;
      return mesh;
  }}

  const torsoGeo = new THREE.CylinderGeometry(0.18, 0.15, 0.5, 32);
  torsoGeo.translate(0, 0.25, 0);
  const torso = new THREE.Mesh(torsoGeo, suitMat);
  torso.castShadow = true;
  
  bones.spine = new THREE.Group();
  bones.spine.add(torso);
  avatarModel.add(bones.spine);

  const headGeo = new THREE.SphereGeometry(0.13, 32, 32);
  headGeo.translate(0, 0.13, 0);
  const head = new THREE.Mesh(headGeo, skinMat);
  head.castShadow = true;
  bones.head = new THREE.Group();
  bones.head.position.set(0, 0.55, 0);
  
  const neck = createBoneMesh(0.04, 0.08, skinMat);
  neck.position.set(0, 0, 0);
  bones.head.add(neck);
  bones.head.add(head);
  bones.spine.add(bones.head);

  function createArm(isRight) {{
      const sign = isRight ? 1 : -1;
      const prefix = isRight ? 'r' : 'l';
      
      const shoulder = new THREE.Group();
      shoulder.position.set(sign * 0.22, 0.45, 0);
      shoulder.add(createJoint(0.06));
      
      const armMesh = createBoneMesh(0.05, 0.25, suitMat);
      shoulder.add(armMesh);
      bones.spine.add(shoulder);
      bones[prefix + 'Arm'] = shoulder;

      const elbow = new THREE.Group();
      elbow.position.set(0, -0.25, 0);
      elbow.add(createJoint(0.045));
      const foreArmMesh = createBoneMesh(0.04, 0.25, skinMat);
      elbow.add(foreArmMesh);
      shoulder.add(elbow);
      bones[prefix + 'ForeArm'] = elbow;

      const wrist = new THREE.Group();
      wrist.position.set(0, -0.25, 0);
      wrist.add(createJoint(0.03));
      
      const handGeo = new THREE.BoxGeometry(0.08, 0.1, 0.02);
      handGeo.translate(0, -0.05, 0);
      const handMesh = new THREE.Mesh(handGeo, skinMat);
      handMesh.castShadow = true;
      wrist.add(handMesh);
      elbow.add(wrist);
      bones[prefix + 'Hand'] = wrist;

      bones[prefix + 'Fingers'] = [];
      const fX = [-0.03, -0.015, 0, 0.015, 0.03]; 
      for(let f=0; f<5; f++) {{
          const fingerBones = [];
          let parent = wrist;
          for(let j=0; j<3; j++) {{
              const joint = new THREE.Group();
              if(j===0) {{
                 joint.position.set(sign * fX[f], -0.1, 0);
              }} else {{
                 joint.position.set(0, -0.03, 0);
              }}
              const phalanx = createBoneMesh(0.008, 0.03, skinMat);
              joint.add(phalanx);
              parent.add(joint);
              fingerBones.push(joint);
              parent = joint;
          }}
          bones[prefix + 'Fingers'].push(fingerBones);
      }}
  }}

  createArm(true);
  createArm(false);

  for(let key in bones) {{
      if(key.includes('Fingers')) {{
          for(let f=0; f<5; f++) {{
              for(let j=0; j<3; j++) {{
                  bones[key][f][j].baseRot = bones[key][f][j].quaternion.clone();
              }}
          }}
      }} else {{
          baseRotations[key] = bones[key].quaternion.clone();
      }}
  }}

  scene.add(avatarModel);
  avatarModel.position.set(0, -0.4, 0);
  camera.position.set(0, 0.3, 1.8);
  camera.lookAt(new THREE.Vector3(0, 0.3, 0));
}}

var DB = {json_db};

var currentPose = JSON.parse(JSON.stringify(DB.words['IDLE']));
var targetPose = JSON.parse(JSON.stringify(currentPose));
var signQueue = [];
var isAnimating = false;

function eulerToQuat(arr) {{
  var e = new THREE.Euler(arr[0], arr[1], arr[2], 'XYZ');
  return new THREE.Quaternion().setFromEuler(e);
}}

function getPoseForToken(token) {{
  if(DB.words[token]) return DB.words[token];
  return DB.words['IDLE'];
}}

function setTargetPose(poseObj) {{
  for(var k in poseObj) {{
      if(k === 'rFingers' || k === 'lFingers') {{
          targetPose[k] = JSON.parse(JSON.stringify(poseObj[k]));
      }} else {{
          targetPose[k] = poseObj[k];
      }}
  }}
}}

function processSignQueue() {{
  if (signQueue.length === 0) {{
    setTargetPose(DB.words['IDLE']);
    isAnimating = false;
    document.getElementById('debug_text').style.display = 'none';
    return;
  }}
  
  isAnimating = true;
  var token = signQueue.shift();
  
  var dt = document.getElementById('debug_text');
  dt.innerHTML = '<span style="color:#0f0">[LSC]</span> Seña: ' + token;
  dt.style.display = 'block';

  setTargetPose(getPoseForToken(token));
  setTimeout(processSignQueue, 1500);
}}

function processText(text) {{
    var cleanText = text.toUpperCase()
        .replace(/[ÁÄÂÀ]/g, 'A')
        .replace(/[ÉËÊÈ]/g, 'E')
        .replace(/[ÍÏÎÌ]/g, 'I')
        .replace(/[ÓÖÔÒ]/g, 'O')
        .replace(/[ÚÜÛÙ]/g, 'U')
        .replace(/[^A-Z ]/g, '')
        .trim();
        
    if (!cleanText) return [];
    
    // Check if the entire sentence matches a key like "COMO ESTAS"
    if (DB.words[cleanText]) {{
        return [cleanText];
    }}

    var words = cleanText.split(/\s+/);
    var tokens = [];
    
    for(var i=0; i<words.length; i++) {{
        var w = words[i];
        if(DB.words[w]) {{
            tokens.push(w);
        }}
        // Se quitó el deletreo de acuerdo a la solicitud
    }}
    return tokens;
}}

window.signSentence = function(text) {{
  var tokens = processText(text);
  if (tokens.length === 0) return;
  
  signQueue = signQueue.concat(tokens);
  if (!isAnimating) processSignQueue();
}};

window.signWord = window.signSentence;
window.spellWord = window.signSentence;

function lerp(start, end, amt) {{
  return (1 - amt) * start + amt * end;
}}

function animate() {{
  requestAnimationFrame(animate);
  var dt = clock.getDelta();
  if (dt > 0.1) dt = 0.016;

  var w = window.innerWidth;
  var h = window.innerHeight;
  if(w > 0 && h > 0 && renderer.domElement.clientWidth !== w) {{
      camera.aspect = w/h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
  }}

  for (var key in targetPose) {{
      if(key === 'rFingers' || key === 'lFingers') continue;
      for (var i = 0; i < 3; i++) {{
          currentPose[key][i] = lerp(currentPose[key][i], targetPose[key][i], 8.0 * dt);
      }}
  }}
  
  for(let hand of ['rFingers', 'lFingers']) {{
      for(let f=0; f<5; f++) {{
          for(let j=0; j<3; j++) {{
              currentPose[hand][f][j] = lerp(currentPose[hand][f][j], targetPose[hand][f][j], 12.0 * dt);
          }}
      }}
  }}

  for (var key in currentPose) {{
      if(key === 'rFingers' || key === 'lFingers') continue;
      if (bones[key] && baseRotations[key]) {{
          var targetQ = baseRotations[key].clone().multiply(eulerToQuat(currentPose[key]));
          bones[key].quaternion.copy(targetQ); 
      }}
  }}

  for(let hand of ['rFingers', 'lFingers']) {{
      for(let f=0; f<5; f++) {{
          for(let j=0; j<3; j++) {{
              let bone = bones[hand][f][j];
              let rotVal = currentPose[hand][f][j]; 
              let tQ = bone.baseRot.clone().multiply(eulerToQuat([rotVal, 0, 0]));
              bone.quaternion.copy(tQ);
          }}
      }}
  }}

  if (!isAnimating && avatarModel) {{
     var t = clock.elapsedTime;
     avatarModel.position.y = -0.4 + Math.sin(t * 1.5) * 0.01; 
  }}

  renderer.render(scene, camera);
}}

init();
function init() {{
  setupScene();
  buildThreeJSAvatar();
  animate();
}}

}})();
</script>
</body>
</html>
"""

with open(r"c:\Users\jorge ochoa\ibi\Ibi-App\flutter_app\assets\html\avatar3d.html", "w", encoding="utf-8") as f:
    f.write(html_content)

print("avatar3d.html updated successfully with 100 words and COMO ESTAS, spelling removed.")
