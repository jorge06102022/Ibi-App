import os

html_top = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<style>
  html,body{margin:0;padding:0;overflow:hidden;background:transparent;width:100%;height:100%}
  canvas{display:block;width:100%;height:100%}
  #loading {position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);color:white;background:rgba(0,0,0,0.5);padding:10px;border-radius:10px;font-family:sans-serif;z-index:9999;}
  #debug_text {position:absolute;bottom:10px;left:50%;transform:translateX(-50%);color:white;background:rgba(0,100,200,0.8);padding:10px;border-radius:10px;font-family:sans-serif;z-index:9999;display:none;font-size:18px;font-weight:bold;}
</style>
</head>
<body>
<div id="loading">Cargando Avatar...</div>
<div id="debug_text"></div>
<script src="three.min.js"></script>
<script src="GLTFLoader.js"></script>
<script src="avatar.js"></script>
<script>
(function(){
'use strict';

var scene, camera, renderer, clock;
var avatarModel = null;
var skeleton = null;
var bones = {};
var baseRotations = {};

var BONE_NAMES = {
  spine:      ['mixamorig:spine', 'spine'],
  neck:       ['mixamorig:neck', 'neck'],
  head:       ['mixamorig:head', 'head'],
  
  rShoulder:  ['mixamorig:rightshoulder', 'rightshoulder'],
  rArm:       ['mixamorig:rightarm', 'rightarm'],
  rForeArm:   ['mixamorig:rightforearm', 'rightforearm'],
  rHand:      ['mixamorig:righthand', 'righthand'],
  
  rThumb1:    ['mixamorig:righthandthumb1', 'righthandthumb1'],
  rThumb2:    ['mixamorig:righthandthumb2', 'righthandthumb2'],
  rThumb3:    ['mixamorig:righthandthumb3', 'righthandthumb3'],
  rIndex1:    ['mixamorig:righthandindex1', 'righthandindex1'],
  rIndex2:    ['mixamorig:righthandindex2', 'righthandindex2'],
  rIndex3:    ['mixamorig:righthandindex3', 'righthandindex3'],
  rMiddle1:   ['mixamorig:righthandmiddle1', 'righthandmiddle1'],
  rMiddle2:   ['mixamorig:righthandmiddle2', 'righthandmiddle2'],
  rMiddle3:   ['mixamorig:righthandmiddle3', 'righthandmiddle3'],
  rRing1:     ['mixamorig:righthandring1', 'righthandring1'],
  rRing2:     ['mixamorig:righthandring2', 'righthandring2'],
  rRing3:     ['mixamorig:righthandring3', 'righthandring3'],
  rPinky1:    ['mixamorig:righthandpinky1', 'righthandpinky1'],
  rPinky2:    ['mixamorig:righthandpinky2', 'righthandpinky2'],
  
  lShoulder:  ['mixamorig:leftshoulder', 'leftshoulder'],
  lArm:       ['mixamorig:leftarm', 'leftarm'],
  lForeArm:   ['mixamorig:leftforearm', 'leftforearm'],
  lHand:      ['mixamorig:lefthand', 'lefthand']
};

function setupScene() {
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0xffffff);
  var w = window.innerWidth || 300;
  var h = window.innerHeight || 300;
  camera = new THREE.PerspectiveCamera(35, w/h, 0.1, 100);
  
  renderer = new THREE.WebGLRenderer({antialias:true});
  renderer.setSize(w, h);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  document.body.appendChild(renderer.domElement);

  var hemiLight = new THREE.HemisphereLight(0xffffff, 0x444444, 1.0);
  hemiLight.position.set(0, 20, 0);
  scene.add(hemiLight);

  var dirLight = new THREE.DirectionalLight(0xffffff, 1.0);
  dirLight.position.set(3, 10, 10);
  scene.add(dirLight);

  var fillLight = new THREE.DirectionalLight(0x90b0d0, 0.5);
  fillLight.position.set(-3, 10, -10);
  scene.add(fillLight);

  clock = new THREE.Clock();
}

function findBone(object, possibleNames) {
  var found = null;
  object.traverse(function(child) {
    if (child.name) {
      var lowerName = child.name.replace(':', '').toLowerCase();
      for(var i=0; i<possibleNames.length; i++) {
        var searchName = possibleNames[i].replace(':', '').toLowerCase();
        if (lowerName === searchName || lowerName.endsWith(searchName)) {
          found = child;
        }
      }
    }
  });
  return found;
}

function loadAvatar() {
  var loader = new THREE.GLTFLoader();
  try {
    var binaryString = atob(avatar_b64);
    var bytes = new Uint8Array(binaryString.length);
    for (var i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
  } catch(e) {
    console.error("Base64 error", e);
    return;
  }

  loader.parse(bytes.buffer, '', function(gltf) {
    document.getElementById('loading').style.display = 'none';
    avatarModel = gltf.scene;
    
    avatarModel.traverse(function(node) {
      if (node.isMesh) {
         if(node.isSkinnedMesh && !skeleton) skeleton = node.skeleton;
      }
    });

    scene.add(avatarModel);

    // Auto-frame scale
    var box = new THREE.Box3().setFromObject(avatarModel);
    var size = box.getSize(new THREE.Vector3());
    if (size.y > 0) {
      var s = 1.6 / size.y;
      avatarModel.scale.set(s, s, s);
      box.setFromObject(avatarModel);
      var c = box.getCenter(new THREE.Vector3());
      avatarModel.position.x -= c.x;
      avatarModel.position.z -= c.z;
      avatarModel.position.y -= box.min.y;
      avatarModel.rotation.y = Math.PI; // ROTAR AL FRENTE
      
      camera.position.set(0, 1.4, 2.5);
      camera.lookAt(new THREE.Vector3(0, 1.0, 0));
    }

    for (var key in BONE_NAMES) {
      var b = findBone(avatarModel, BONE_NAMES[key]);
      if (b) {
        bones[key] = b;
        baseRotations[key] = b.quaternion.clone();
      }
    }
  });
}

// Helpers 
var STRAIGHT = [0,0,0];
var CURVED = [0.0, 0, 0.4];
var CLOSED = [0.0, 0, 1.5];
var SPREAD = [0, 0.2, 0];

var currentPose = {
  rArm: [0,0,0], rForeArm: [0,0,0], rHand: [0,0,0],
  rThumb1: [0,0,0], rThumb2: [0,0,0], rThumb3: [0,0,0],
  rIndex1: [0,0,0], rIndex2: [0,0,0], rIndex3: [0,0,0],
  rMiddle1: [0,0,0], rMiddle2: [0,0,0], rMiddle3: [0,0,0],
  rRing1: [0,0,0], rRing2: [0,0,0], rRing3: [0,0,0],
  rPinky1: [0,0,0], rPinky2: [0,0,0],
  lArm: [0,0,0], lForeArm: [0,0,0], lHand: [0,0,0],
  spine: [0,0,0], head: [0,0,0]
};
var targetPose = JSON.parse(JSON.stringify(currentPose));
var signQueue = [];
var isAnimating = false;

function eulerToQuat(arr) {
  var e = new THREE.Euler(arr[0], arr[1], arr[2], 'XYZ');
  return new THREE.Quaternion().setFromEuler(e);
}

// Generador de poses
var POSES = {};

// IDLE
POSES['IDLE'] = { 
  rArm:[0,0,0], rForeArm:[0,0,0], rHand:[0,0,0], lArm:[0,0,0], lForeArm:[0,0,0], lHand:[0,0,0],
  rThumb1: STRAIGHT, rThumb2: STRAIGHT, rThumb3: STRAIGHT,
  rIndex1: STRAIGHT, rIndex2: STRAIGHT, rIndex3: STRAIGHT,
  rMiddle1: STRAIGHT, rMiddle2: STRAIGHT, rMiddle3: STRAIGHT,
  rRing1: STRAIGHT, rRing2: STRAIGHT, rRing3: STRAIGHT,
  rPinky1: STRAIGHT, rPinky2: STRAIGHT
};

// Brazo levantado base (para la mayoría de letras)
var baseArm = { rArm: [0, 0.5, 1.2], rForeArm: [0, 1.2, 0], rHand: [0, 0, 0] };

// HELPER FUNCTION
function makePose(arm, thumb, index, middle, ring, pinky) {
    return Object.assign({}, arm, {
        rThumb1: thumb, rThumb2: thumb, rThumb3: thumb,
        rIndex1: index, rIndex2: index, rIndex3: index,
        rMiddle1: middle, rMiddle2: middle, rMiddle3: middle,
        rRing1: ring, rRing2: ring, rRing3: ring,
        rPinky1: pinky, rPinky2: pinky
    });
}

// A: Puño, pulgar al lado
POSES['A'] = makePose(baseArm, STRAIGHT, CLOSED, CLOSED, CLOSED, CLOSED);
POSES['A'].rThumb1 = [0, -0.5, 0]; 

// B: Mano plana
POSES['B'] = makePose(baseArm, CLOSED, STRAIGHT, STRAIGHT, STRAIGHT, STRAIGHT);
POSES['B'].rThumb1 = [0, 0.8, 0.5];

// C: Forma de C
POSES['C'] = makePose(baseArm, CURVED, CURVED, CURVED, CURVED, CURVED);

// D: Indice arriba, circulo con los demas
POSES['D'] = makePose(baseArm, CLOSED, STRAIGHT, CLOSED, CLOSED, CLOSED);
POSES['D'].rThumb1 = [0, 0.5, 0.5];

// E: Dedos curvados hacia la palma, pulgar debajo
POSES['E'] = makePose(baseArm, CLOSED, CURVED, CURVED, CURVED, CURVED);
POSES['E'].rThumb1 = [0, 0.8, 0.8];

// F: Indice y pulgar tocandose, los demas arriba
POSES['F'] = makePose(baseArm, CURVED, CURVED, STRAIGHT, STRAIGHT, STRAIGHT);

// G: Indice y pulgar horizontal
POSES['G'] = makePose({rArm:[0,0.5,1.2], rForeArm:[0,1.2,-1.5], rHand:[0,0,0]}, STRAIGHT, STRAIGHT, CLOSED, CLOSED, CLOSED);

// H: Indice y medio horizontal
POSES['H'] = makePose({rArm:[0,0.5,1.2], rForeArm:[0,1.2,-1.5], rHand:[0,0,0]}, CLOSED, STRAIGHT, STRAIGHT, CLOSED, CLOSED);

// I: Meñique arriba
POSES['I'] = makePose(baseArm, CLOSED, CLOSED, CLOSED, CLOSED, STRAIGHT);

// J: Meñique arriba (igual que I para estatico)
POSES['J'] = POSES['I'];

// K: Indice y medio arriba, pulgar tocando medio
POSES['K'] = makePose(baseArm, STRAIGHT, STRAIGHT, STRAIGHT, CLOSED, CLOSED);
POSES['K'].rThumb1 = [0,0.5,0];

// L: Indice y pulgar en L
POSES['L'] = makePose(baseArm, STRAIGHT, STRAIGHT, CLOSED, CLOSED, CLOSED);

// M: 3 dedos sobre el pulgar apuntando abajo
POSES['M'] = makePose({rArm:[0, 0.5, 1.2], rForeArm:[0, 1.2, 0], rHand:[0, 0, -1.5]}, CLOSED, STRAIGHT, STRAIGHT, STRAIGHT, CLOSED);

// N: 2 dedos sobre el pulgar
POSES['N'] = makePose({rArm:[0, 0.5, 1.2], rForeArm:[0, 1.2, 0], rHand:[0, 0, -1.5]}, CLOSED, STRAIGHT, STRAIGHT, CLOSED, CLOSED);

// O: Circulo con todos los dedos
POSES['O'] = makePose(baseArm, CURVED, CURVED, CURVED, CURVED, CURVED);

// P: K apuntando abajo
POSES['P'] = makePose({rArm:[0,0.5,1.2], rForeArm:[0,1.2,0], rHand:[0,0,-1.5]}, STRAIGHT, STRAIGHT, STRAIGHT, CLOSED, CLOSED);

// Q: L apuntando abajo
POSES['Q'] = makePose({rArm:[0,0.5,1.2], rForeArm:[0,1.2,0], rHand:[0,0,-1.5]}, STRAIGHT, STRAIGHT, CLOSED, CLOSED, CLOSED);

// R: Indice y medio cruzados
POSES['R'] = makePose(baseArm, CLOSED, STRAIGHT, STRAIGHT, CLOSED, CLOSED);

// S: Puño, pulgar sobre dedos
POSES['S'] = makePose(baseArm, CLOSED, CLOSED, CLOSED, CLOSED, CLOSED);

// T: Puño, pulgar entre indice y medio
POSES['T'] = makePose(baseArm, STRAIGHT, CLOSED, CLOSED, CLOSED, CLOSED);
POSES['T'].rThumb1 = [0, 0.5, 0];

// U: Indice y medio juntos arriba
POSES['U'] = makePose(baseArm, CLOSED, STRAIGHT, STRAIGHT, CLOSED, CLOSED);

// V: Indice y medio separados (Paz)
POSES['V'] = makePose(baseArm, CLOSED, STRAIGHT, STRAIGHT, CLOSED, CLOSED);
POSES['V'].rIndex1 = [0, -0.2, 0];
POSES['V'].rMiddle1 = [0, 0.2, 0];

// W: Indice, medio, anular separados
POSES['W'] = makePose(baseArm, CLOSED, STRAIGHT, STRAIGHT, STRAIGHT, CLOSED);
POSES['W'].rIndex1 = [0, -0.2, 0];
POSES['W'].rRing1 = [0, 0.2, 0];

// X: Indice en gancho
POSES['X'] = makePose(baseArm, CLOSED, CURVED, CLOSED, CLOSED, CLOSED);

// Y: Pulgar y meñique extendidos
POSES['Y'] = makePose(baseArm, STRAIGHT, CLOSED, CLOSED, CLOSED, STRAIGHT);

// Z: Indice arriba (dibuja Z)
POSES['Z'] = makePose(baseArm, CLOSED, STRAIGHT, CLOSED, CLOSED, CLOSED);

// PALABRAS (Señas)
POSES['HOLA'] = Object.assign({}, POSES['B']);
POSES['HOLA'].rArm = [0, 0, 1.2];
POSES['HOLA'].rForeArm = [0, 0, 0];

POSES['GRACIAS'] = Object.assign({}, POSES['B']);
POSES['GRACIAS'].rArm = [0.8, 0, 0.3];
POSES['GRACIAS'].rForeArm = [0, 1.2, 0];
POSES['GRACIAS'].rHand = [0, 0.5, 0];

POSES['BIEN'] = Object.assign({}, POSES['B']);
POSES['BIEN'].rArm = [0.2, 0, 0.2];
POSES['BIEN'].rForeArm = [0, 1.0, 0];
POSES['BIEN'].rHand = [0, 0.5, 0];

POSES['MAL'] = Object.assign({}, POSES['B']);
POSES['MAL'].rArm = [0.5, 0, 0.2];
POSES['MAL'].rForeArm = [0, 1.0, 0];
POSES['MAL'].rHand = [0, -1.0, 0];

POSES['AMOR'] = Object.assign({}, POSES['S']);
POSES['AMOR'].rArm = [0.5, 0, 0.5];
POSES['AMOR'].rForeArm = [0, 1.5, 0];
POSES['AMOR'].lArm = [0.5, 0, -0.5];
POSES['AMOR'].lForeArm = [0, -1.5, 0];
POSES['AMOR'].lHand = [0, 0, 0];

function getPoseForWord(word) {
  return POSES[word] || POSES['A']; // Fallback a 'A'
}

function setTargetPose(poseObj) {
  for(var k in targetPose) {
    targetPose[k] = POSES['IDLE'][k] ? [...POSES['IDLE'][k]] : [0,0,0];
  }
  for(var k in poseObj) {
    if (targetPose[k]) targetPose[k] = [...poseObj[k]];
  }
}

function processSignQueue() {
  if (signQueue.length === 0) {
    setTargetPose(POSES['IDLE']);
    isAnimating = false;
    return;
  }
  isAnimating = true;
  var word = signQueue.shift();
  setTargetPose(getPoseForWord(word));
  
  setTimeout(processSignQueue, 1000);
}

window.signSentence = function(text) {
  document.getElementById('debug_text').innerText = "Seña: " + text;
  document.getElementById('debug_text').style.display = 'block';

  var cleanText = text.toUpperCase().replace(/[^\\w\\sÁÉÍÓÚÑ]/g, '').trim();
  if (cleanText.length === 0) return;
  
  var words = cleanText.split(/\\s+/);
  signQueue = words;
  
  if (!isAnimating) {
    processSignQueue();
  }
  
  setTimeout(function() {
    document.getElementById('debug_text').style.display = 'none';
  }, (words.length * 1000) + 1000);
};

window.spellWord = function(text) {
  document.getElementById('debug_text').innerText = "Deletreo: " + text;
  document.getElementById('debug_text').style.display = 'block';

  var cleanText = text.toUpperCase().replace(/[^A-Z]/g, '').trim();
  if (cleanText.length === 0) return;
  
  var letters = cleanText.split("");
  signQueue = letters;
  
  if (!isAnimating) {
    processSignQueue();
  }
  
  setTimeout(function() {
    document.getElementById('debug_text').style.display = 'none';
  }, (letters.length * 1000) + 1000);
};

window.signWord = window.signSentence;

function lerp(start, end, amt) {
  return (1 - amt) * start + amt * end;
}

function animate() {
  requestAnimationFrame(animate);
  var dt = clock.getDelta();
  if (dt > 0.1) dt = 0.016;

  var w = window.innerWidth;
  var h = window.innerHeight;
  if(w > 0 && h > 0 && renderer.domElement.clientWidth !== w) {
      camera.aspect = w/h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
  }

  for (var key in currentPose) {
    for (var i = 0; i < 3; i++) {
      currentPose[key][i] = lerp(currentPose[key][i], targetPose[key][i], 12.0 * dt);
    }
  }

  for (var key in currentPose) {
    if (bones[key] && baseRotations[key]) {
      var targetQ = baseRotations[key].clone().multiply(eulerToQuat(currentPose[key]));
      bones[key].quaternion.copy(targetQ);
    }
  }

  if (!isAnimating && avatarModel) {
     var t = clock.elapsedTime;
     avatarModel.position.y = Math.sin(t * 1.5) * 0.005; 
  }

  if (avatarModel) {
      avatarModel.updateMatrixWorld(true);
  }

  if (skeleton) skeleton.update();

  renderer.render(scene, camera);
}

init();
function init() {
  setupScene();
  loadAvatar();
  animate();
}

})();
</script>
</body>
</html>
"""

with open('connectvoice_app/assets/html/avatar3d.html', 'w', encoding='utf-8') as f:
    f.write(html_top)
