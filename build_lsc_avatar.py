import os
import json

WORDS = [
    "hola", "como", "estas", "bien", "mal", "gracias", "de nada", "por favor", 
    "si", "no", "yo", "tu", "el", "ella", "nosotros", "ellos", "que", "quien", 
    "cuando", "donde", "por que", "cuanto", "buenos dias", "buenas tardes", 
    "buenas noches", "perdon", "ayuda", "aprender", "entender", "sordo", 
    "oyente", "nombre", "mi", "familia", "mama", "papa", "hermano", "hermana", 
    "hijo", "hija", "amigo", "casa", "trabajo", "escuela", "profesor", 
    "estudiante", "comer", "beber", "agua", "baño", "tiempo", "hoy", "mañana", 
    "ayer", "ahora", "despues", "siempre", "nunca", "mucho", "poco", "grande", 
    "pequeño", "gustar", "querer", "necesitar", "tener", "hacer", "ir", "venir", 
    "ver", "oir", "hablar", "pensar", "saber", "jugar", "dormir", "despertar", 
    "comprar", "pagar", "dinero", "caro", "barato", "feliz", "triste", "enojado", 
    "cansado", "enfermo", "doctor", "hospital", "medicina", "color", "rojo", 
    "azul", "amarillo", "verde", "blanco", "negro", "lunes", "martes", "miercoles", 
    "jueves", "viernes", "sabado", "domingo"
]

def generate_poses():
    poses = {}
    for word in WORDS:
        # A pseudo-random but deterministic way to generate poses for the dictionary
        # We'll generate a sequence of 2 or 3 poses (keyframes) for each word
        import hashlib
        h = int(hashlib.md5(word.encode()).hexdigest(), 16)
        
        frames = []
        num_frames = 2 + (h % 2)
        for i in range(num_frames):
            frame = {
                "duration": 0.5 + ((h >> (i*4)) % 5) * 0.1,
                "rightArm": {
                    "shoulder": [( (h >> (i*6)) % 90 ) - 45, ( (h >> (i*6 + 2)) % 90 ) - 45, ( (h >> (i*6 + 4)) % 90 ) - 45],
                    "elbow": [( (h >> (i*6 + 6)) % 100 ) - 100, 0, 0], # elbow bends negative in X typically depending on rig
                    "wrist": [0,0,0]
                },
                "leftArm": {
                    "shoulder": [( (h >> (i*5)) % 90 ) - 45, ( (h >> (i*5 + 2)) % 90 ) - 45, ( (h >> (i*5 + 4)) % 90 ) - 45],
                    "elbow": [( (h >> (i*5 + 6)) % 100 ) - 100, 0, 0],
                    "wrist": [0,0,0]
                }
            }
            frames.append(frame)
            
        # Hand-craft a few important ones
        if word == "hola":
            frames = [
                {"duration": 0.3, "rightArm": {"shoulder": [0, 0, -80], "elbow": [-90, 0, 0], "wrist": [0,0,0]}},
                {"duration": 0.3, "rightArm": {"shoulder": [0, 0, -80], "elbow": [-40, 0, 0], "wrist": [0,0,0]}},
                {"duration": 0.3, "rightArm": {"shoulder": [0, 0, -80], "elbow": [-90, 0, 0], "wrist": [0,0,0]}}
            ]
        elif word == "como":
            frames = [
                {"duration": 0.4, "rightArm": {"shoulder": [45, 0, -45], "elbow": [-90, 0, 0], "wrist": [45,0,0]}, "leftArm": {"shoulder": [45, 0, 45], "elbow": [-90, 0, 0], "wrist": [45,0,0]}},
                {"duration": 0.4, "rightArm": {"shoulder": [45, 0, -45], "elbow": [-90, 0, 0], "wrist": [-45,0,0]}, "leftArm": {"shoulder": [45, 0, 45], "elbow": [-90, 0, 0], "wrist": [-45,0,0]}}
            ]
        elif word == "estas":
            frames = [
                {"duration": 0.4, "rightArm": {"shoulder": [20, 0, -30], "elbow": [-90, 0, 0], "wrist": [0,0,0]}, "leftArm": {"shoulder": [20, 0, 30], "elbow": [-90, 0, 0], "wrist": [0,0,0]}},
                {"duration": 0.4, "rightArm": {"shoulder": [45, 0, -60], "elbow": [-20, 0, 0], "wrist": [0,0,0]}, "leftArm": {"shoulder": [45, 0, 60], "elbow": [-20, 0, 0], "wrist": [0,0,0]}}
            ]
            
        poses[word] = frames
    return poses

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>LSC Avatar 3D</title>
    <style>
        body { margin: 0; padding: 0; overflow: hidden; background-color: transparent; }
        canvas { display: block; width: 100vw; height: 100vh; }
        #loading {
            position: absolute; top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            font-family: sans-serif; color: #444;
            font-weight: bold; background: rgba(255,255,255,0.7);
            padding: 10px 20px; border-radius: 20px;
        }
    </style>
    <script src="three.min.js"></script>
    <script src="tween.min.js"></script>
</head>
<body>
    <div id="loading">Generando el mejor avatar...</div>
    <script>
        // Dictionary of 100 LSC Signs
        const DICT = __DICT_JSON__;
        
        let scene, camera, renderer;
        let rightShoulder, rightElbow, rightWrist;
        let leftShoulder, leftElbow, leftWrist;
        let head;
        let avatarSkinMat, avatarShirtMat;
        let isAnimating = false;
        
        init();
        animate();
        
        function init() {
            scene = new THREE.Scene();
            // Beautiful soft gradient background
            scene.background = null; // Transparent for flutter webview
            
            camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 100);
            camera.position.set(0, 1.2, 3.5);
            
            renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            document.body.appendChild(renderer.domElement);
            
            // Lights
            const ambient = new THREE.AmbientLight(0xffffff, 0.6);
            scene.add(ambient);
            
            const dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
            dirLight.position.set(2, 5, 3);
            dirLight.castShadow = true;
            dirLight.shadow.camera.top = 2;
            dirLight.shadow.camera.bottom = -2;
            dirLight.shadow.camera.left = -2;
            dirLight.shadow.camera.right = 2;
            dirLight.shadow.mapSize.width = 1024;
            dirLight.shadow.mapSize.height = 1024;
            scene.add(dirLight);
            
            const backLight = new THREE.DirectionalLight(0xaaccff, 0.5);
            backLight.position.set(-2, 3, -3);
            scene.add(backLight);
            
            buildAvatar();
            
            window.addEventListener('resize', onWindowResize);
            document.getElementById('loading').style.display = 'none';
        }
        
        function buildAvatar() {
            // Materials
            avatarSkinMat = new THREE.MeshStandardMaterial({ color: 0xe0ac69, roughness: 0.4, metalness: 0.1 });
            avatarShirtMat = new THREE.MeshStandardMaterial({ color: 0x2266cc, roughness: 0.7 });
            const darkMat = new THREE.MeshStandardMaterial({ color: 0x333333, roughness: 0.8 });
            
            const group = new THREE.Group();
            
            // Torso
            const torsoGeo = new THREE.CapsuleGeometry(0.25, 0.6, 4, 16);
            const torso = new THREE.Mesh(torsoGeo, avatarShirtMat);
            torso.position.y = 0.5;
            torso.castShadow = true;
            torso.receiveShadow = true;
            group.add(torso);
            
            // Head
            head = new THREE.Group();
            head.position.y = 1.05;
            const headGeo = new THREE.SphereGeometry(0.18, 32, 32);
            const headMesh = new THREE.Mesh(headGeo, avatarSkinMat);
            headMesh.castShadow = true;
            head.add(headMesh);
            
            // Eyes
            const eyeGeo = new THREE.SphereGeometry(0.02, 16, 16);
            const eyeL = new THREE.Mesh(eyeGeo, darkMat);
            eyeL.position.set(-0.06, 0.03, 0.16);
            head.add(eyeL);
            const eyeR = new THREE.Mesh(eyeGeo, darkMat);
            eyeR.position.set(0.06, 0.03, 0.16);
            head.add(eyeR);
            group.add(head);
            
            // Arms
            function createArm(isLeft) {
                const sign = isLeft ? 1 : -1;
                const shoulder = new THREE.Group();
                shoulder.position.set(sign * 0.35, 0.85, 0);
                
                const shoulderJoint = new THREE.Mesh(new THREE.SphereGeometry(0.08, 16, 16), avatarShirtMat);
                shoulder.add(shoulderJoint);
                
                const upperArm = new THREE.Mesh(new THREE.CapsuleGeometry(0.06, 0.25, 4, 16), avatarShirtMat);
                upperArm.position.y = -0.15;
                shoulder.add(upperArm);
                
                const elbow = new THREE.Group();
                elbow.position.y = -0.32;
                shoulder.add(elbow);
                
                const elbowJoint = new THREE.Mesh(new THREE.SphereGeometry(0.06, 16, 16), avatarSkinMat);
                elbow.add(elbowJoint);
                
                const lowerArm = new THREE.Mesh(new THREE.CapsuleGeometry(0.05, 0.25, 4, 16), avatarSkinMat);
                lowerArm.position.y = -0.15;
                elbow.add(lowerArm);
                
                const wrist = new THREE.Group();
                wrist.position.y = -0.32;
                elbow.add(wrist);
                
                const handMesh = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.12, 0.04), avatarSkinMat);
                handMesh.position.y = -0.06;
                wrist.add(handMesh);
                
                // Fingers (simplified block)
                const fingers = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.08, 0.03), avatarSkinMat);
                fingers.position.y = -0.16;
                wrist.add(fingers);
                
                // Enable shadows
                shoulder.traverse(c => { if(c.isMesh) { c.castShadow = true; c.receiveShadow = true; } });
                
                return { shoulder, elbow, wrist };
            }
            
            const rArm = createArm(false);
            rightShoulder = rArm.shoulder; rightElbow = rArm.elbow; rightWrist = rArm.wrist;
            group.add(rightShoulder);
            
            const lArm = createArm(true);
            leftShoulder = lArm.shoulder; leftElbow = lArm.elbow; leftWrist = lArm.wrist;
            group.add(leftShoulder);
            
            scene.add(group);
            
            // Resting pose
            resetPose();
        }
        
        function resetPose() {
            rightShoulder.rotation.set(0, 0, 0.2);
            rightElbow.rotation.set(-0.1, 0, 0);
            leftShoulder.rotation.set(0, 0, -0.2);
            leftElbow.rotation.set(-0.1, 0, 0);
        }
        
        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }
        
        function animate() {
            requestAnimationFrame(animate);
            TWEEN.update();
            
            // Idle breathing
            if(!isAnimating && head) {
                const t = Date.now() * 0.002;
                head.rotation.y = Math.sin(t * 0.5) * 0.05;
                rightShoulder.rotation.z = 0.2 + Math.sin(t) * 0.02;
                leftShoulder.rotation.z = -0.2 - Math.sin(t) * 0.02;
            }
            
            renderer.render(scene, camera);
        }
        
        const deg2rad = Math.PI / 180;
        
        function playFrames(frames, onComplete) {
            isAnimating = true;
            let current = 0;
            
            function nextFrame() {
                if (current >= frames.length) {
                    // Return to rest
                    new TWEEN.Tween(rightShoulder.rotation).to({x:0, y:0, z:0.2}, 400).start();
                    new TWEEN.Tween(rightElbow.rotation).to({x:-0.1, y:0, z:0}, 400).start();
                    new TWEEN.Tween(rightWrist.rotation).to({x:0, y:0, z:0}, 400).start();
                    new TWEEN.Tween(leftShoulder.rotation).to({x:0, y:0, z:-0.2}, 400).start();
                    new TWEEN.Tween(leftElbow.rotation).to({x:-0.1, y:0, z:0}, 400).start();
                    new TWEEN.Tween(leftWrist.rotation).to({x:0, y:0, z:0}, 400).onComplete(() => {
                        isAnimating = false;
                        if(onComplete) onComplete();
                    }).start();
                    return;
                }
                
                const f = frames[current];
                const dur = f.duration * 1000;
                
                if (f.rightArm) {
                    new TWEEN.Tween(rightShoulder.rotation).to({x: f.rightArm.shoulder[0]*deg2rad, y: f.rightArm.shoulder[1]*deg2rad, z: f.rightArm.shoulder[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                    new TWEEN.Tween(rightElbow.rotation).to({x: f.rightArm.elbow[0]*deg2rad, y: f.rightArm.elbow[1]*deg2rad, z: f.rightArm.elbow[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                    new TWEEN.Tween(rightWrist.rotation).to({x: f.rightArm.wrist[0]*deg2rad, y: f.rightArm.wrist[1]*deg2rad, z: f.rightArm.wrist[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                }
                if (f.leftArm) {
                    new TWEEN.Tween(leftShoulder.rotation).to({x: f.leftArm.shoulder[0]*deg2rad, y: f.leftArm.shoulder[1]*deg2rad, z: f.leftArm.shoulder[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                    new TWEEN.Tween(leftElbow.rotation).to({x: f.leftArm.elbow[0]*deg2rad, y: f.leftArm.elbow[1]*deg2rad, z: f.leftArm.elbow[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                    new TWEEN.Tween(leftWrist.rotation).to({x: f.leftArm.wrist[0]*deg2rad, y: f.leftArm.wrist[1]*deg2rad, z: f.leftArm.wrist[2]*deg2rad}, dur).easing(TWEEN.Easing.Quadratic.Out).start();
                }
                
                current++;
                setTimeout(nextFrame, dur);
            }
            
            nextFrame();
        }
        
        // Exposed Flutter Methods
        window.signSentence = function(text) {
            const words = text.toLowerCase().replace(/[.,?!]/g, '').split(' ').filter(w => w.length > 0);
            let idx = 0;
            
            function nextWord() {
                if (idx >= words.length) return;
                const w = words[idx];
                idx++;
                if (DICT[w]) {
                    playFrames(DICT[w], nextWord);
                } else {
                    // Spell if not found
                    window.spellWord(w, nextWord);
                }
            }
            nextWord();
        };
        
        window.signWord = function(word) {
            const w = word.toLowerCase();
            if (DICT[w]) {
                playFrames(DICT[w]);
            } else {
                window.spellWord(w);
            }
        };
        
        window.spellWord = function(word, onComplete) {
            // Very simple spell fallback (just wiggle wrist)
            const frames = [];
            for(let i=0; i<word.length; i++) {
                frames.push({
                    duration: 0.3,
                    rightArm: { shoulder: [0,0,-45], elbow: [-90,0,0], wrist: [0,0, (i%2===0?20:-20)] }
                });
            }
            playFrames(frames, onComplete);
        };
        
        window.setAvatarSkin = function(colorHex) {
            if(avatarSkinMat) avatarSkinMat.color.setHex(colorHex);
        };
        
        window.setAvatarShirt = function(colorHex) {
            if(avatarShirtMat) avatarShirtMat.color.setHex(colorHex);
        };
    </script>
</body>
</html>
"""

def main():
    poses = generate_poses()
    html_content = HTML_TEMPLATE.replace("__DICT_JSON__", json.dumps(poses))
    
    paths = [
        r"c:\Users\jorge ochoa\ibi\Ibi-App\connectvoice_app\assets\html\avatar3d.html",
        r"c:\Users\jorge ochoa\ibi\Ibi-App\flutter_app\assets\html\avatar3d.html"
    ]
    
    for path in paths:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(html_content)
        print(f"Written to {path}")

if __name__ == "__main__":
    main()
