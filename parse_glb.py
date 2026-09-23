import struct, json

# Parse GLB to extract JSON chunk
glb_path = 'connectvoice_app/assets/html/hand.glb'
with open(glb_path, 'rb') as f:
    magic, version, length = struct.unpack('<III', f.read(12))
    # JSON chunk
    chunk_len, chunk_type = struct.unpack('<II', f.read(8))
    json_data = f.read(chunk_len).decode('utf-8')

gltf = json.loads(json_data)

nodes = gltf.get('nodes', [])
skins = gltf.get('skins', [])

print("=== ALL NODES ===")
for i, node in enumerate(nodes):
    children = node.get('children', [])
    child_names = [nodes[c].get('name', f'node_{c}') for c in children]
    rot = node.get('rotation', None)
    print(f"  Node {i}: name='{node.get('name','')}' children={children} ({child_names}) rotation={rot}")

print("\n=== SKINS ===")
for i, skin in enumerate(skins):
    joints = skin.get('joints', [])
    joint_names = [nodes[j].get('name', f'node_{j}') for j in joints]
    print(f"  Skin {i}: skeleton_root={skin.get('skeleton','?')}")
    print(f"    joints ({len(joints)}): {joint_names}")

print("\n=== BONE HIERARCHY (tree) ===")
# Build parent map
parent_map = {}
for i, node in enumerate(nodes):
    for c in node.get('children', []):
        parent_map[c] = i

# Find skin joints
if skins:
    joint_set = set(skins[0].get('joints', []))
else:
    joint_set = set(range(len(nodes)))

# Find roots (joints with no parent that is also a joint)
roots = []
for j in joint_set:
    p = parent_map.get(j)
    if p is None or p not in joint_set:
        roots.append(j)

def print_tree(node_idx, depth=0):
    node = nodes[node_idx]
    name = node.get('name', f'node_{node_idx}')
    children_in_skeleton = [c for c in node.get('children', []) if c in joint_set]
    indent = '  ' * depth
    print(f"{indent}{name} (node {node_idx}, {len(children_in_skeleton)} bone children)")
    for c in children_in_skeleton:
        print_tree(c, depth + 1)

for r in roots:
    print_tree(r)

print("\n=== FINGER CHAINS (leaf to root) ===")
# Find leaves (joints with no joint children)
leaves = []
for j in joint_set:
    node = nodes[j]
    children_in_skeleton = [c for c in node.get('children', []) if c in joint_set]
    if len(children_in_skeleton) == 0:
        leaves.append(j)

chains = []
for leaf in leaves:
    chain = []
    cur = leaf
    while cur is not None and cur in joint_set:
        chain.append(nodes[cur].get('name', f'node_{cur}'))
        cur = parent_map.get(cur)
    chain.reverse()
    chains.append(chain)

for i, ch in enumerate(chains):
    print(f"  Chain {i}: {' -> '.join(ch)}")
