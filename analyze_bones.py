import struct, json, math

glb_path = 'connectvoice_app/assets/html/hand.glb'
with open(glb_path, 'rb') as f:
    magic, version, length = struct.unpack('<III', f.read(12))
    chunk_len, chunk_type = struct.unpack('<II', f.read(8))
    json_data = f.read(chunk_len).decode('utf-8')

gltf = json.loads(json_data)
nodes = gltf.get('nodes', [])

# The hierarchy is:
# Bone.020 (wrist root)
#   Bone.016 (palm)
#     Bone.012 -> Bone -> Bone.001 -> Bone.002  (finger A)
#     Bone.013 -> Bone.003 -> Bone.004 -> Bone.005  (finger B)
#     Bone.014 -> Bone.006 -> Bone.007 -> Bone.008  (finger C)
#     Bone.015 -> Bone.009 -> Bone.010 -> Bone.011  (finger D)
#     Bone.021 -> Bone.017 -> Bone.018 -> Bone.019  (thumb)
#     index control, Major control, Ring control, Pinky control

# The control bones hint at which finger is which:
# - "index control" is at node 20, same rotation as Bone.012 (node 3)
#   -> Bone.012 chain is INDEX
# - "Major control" at node 21, same rotation as Bone.012... hmm
# - "Pinky control" at node 22
# - "Ring control" at node 23

# Let's check rotations to match controls to chains
def quat_to_euler(q):
    """Convert quaternion [x,y,z,w] to euler angles"""
    x, y, z, w = q
    # Roll (x)
    sinr = 2 * (w * x + y * z)
    cosr = 1 - 2 * (x * x + y * y)
    roll = math.atan2(sinr, cosr)
    # Pitch (y)
    sinp = 2 * (w * y - z * x)
    pitch = math.asin(max(-1, min(1, sinp)))
    # Yaw (z)
    siny = 2 * (w * z + x * y)
    cosy = 1 - 2 * (y * y + z * z)
    yaw = math.atan2(siny, cosy)
    return (roll, pitch, yaw)

# Check which root bone's rotation matches which control
chain_roots = {
    'Bone.012': 3,   # node 3
    'Bone.013': 7,   # node 7
    'Bone.014': 11,  # node 11
    'Bone.015': 15,  # node 15
}

controls = {
    'index control': 20,
    'Major control': 21,
    'Pinky control': 22,
    'Ring control': 23,
}

print("=== CONTROL BONE ROTATIONS ===")
for name, idx in controls.items():
    rot = nodes[idx].get('rotation', [0,0,0,1])
    euler = quat_to_euler(rot)
    print(f"  {name} (node {idx}): quat={[round(r,4) for r in rot]}  euler=({round(euler[0],3)}, {round(euler[1],3)}, {round(euler[2],3)})")

print("\n=== CHAIN ROOT ROTATIONS ===")
for name, idx in chain_roots.items():
    rot = nodes[idx].get('rotation', [0,0,0,1])
    euler = quat_to_euler(rot)
    print(f"  {name} (node {idx}): quat={[round(r,4) for r in rot]}  euler=({round(euler[0],3)}, {round(euler[1],3)}, {round(euler[2],3)})")

# Match by comparing quaternion values
print("\n=== MATCHING CONTROLS TO CHAINS ===")
for ctrl_name, ctrl_idx in controls.items():
    ctrl_rot = nodes[ctrl_idx].get('rotation', [0,0,0,1])
    best_match = None
    best_dist = 999
    for chain_name, chain_idx in chain_roots.items():
        chain_rot = nodes[chain_idx].get('rotation', [0,0,0,1])
        dist = sum((a-b)**2 for a,b in zip(ctrl_rot, chain_rot)) ** 0.5
        if dist < best_dist:
            best_dist = dist
            best_match = chain_name
    print(f"  {ctrl_name} -> {best_match} (dist={best_dist:.4f})")

# Now check the actual curl axis by looking at the rest pose rotations
print("\n=== BONE REST ROTATIONS (euler, per chain) ===")
finger_chains = {
    'index':  ['Bone.012', 'Bone',     'Bone.001', 'Bone.002'],
    'middle': ['Bone.013', 'Bone.003', 'Bone.004', 'Bone.005'],
    'ring':   ['Bone.014', 'Bone.006', 'Bone.007', 'Bone.008'],
    'pinky':  ['Bone.015', 'Bone.009', 'Bone.010', 'Bone.011'],
    'thumb':  ['Bone.021', 'Bone.017', 'Bone.018', 'Bone.019'],
}

node_by_name = {nodes[i].get('name',''): i for i in range(len(nodes))}

for finger, chain in finger_chains.items():
    print(f"\n  {finger}:")
    for bone_name in chain:
        idx = node_by_name.get(bone_name)
        if idx is not None:
            rot = nodes[idx].get('rotation', [0,0,0,1])
            euler = quat_to_euler(rot)
            print(f"    {bone_name}: euler=({round(euler[0],4)}, {round(euler[1],4)}, {round(euler[2],4)})")
