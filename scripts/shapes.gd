class_name Shapes
extends RefCounted
## Reusable miniature-world mesh kit. Shared materials keep draw resources modest.
static var materials: Dictionary = {}
static var shared_sphere: SphereMesh
static var shared_box: BoxMesh

static func mat(hex: String, glow: bool = false) -> StandardMaterial3D:
	var key = hex+str(glow)
	if materials.has(key): return materials[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = 0.87
	if glow:
		m.emission_enabled = true
		m.emission = Color(hex)
		m.emission_energy_multiplier = 0.7
	materials[key] = m
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: String) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	n.mesh = shape
	n.material_override = mat(color)
	n.position = pos
	parent.add_child(n)
	return n

static func ball(parent: Node3D, pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	if shared_sphere == null:
		shared_sphere = SphereMesh.new()
		shared_sphere.radius = 0.5
		shared_sphere.height = 1.0
		shared_sphere.radial_segments = 16
		shared_sphere.rings = 8
	var n = mesh(parent,shared_sphere,pos,color)
	n.scale = size
	return n

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: String, solid: bool = false) -> MeshInstance3D:
	if shared_box == null:
		shared_box = BoxMesh.new()
		shared_box.size = Vector3.ONE
	var n = mesh(parent,shared_box,pos,color)
	n.scale = size
	if solid: collision(parent,pos,BoxShape3D.new(),size)
	return n

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: String, top: float = -1.0) -> MeshInstance3D:
	var s = CylinderMesh.new()
	s.bottom_radius = radius
	s.top_radius = radius if top < 0 else top
	s.height = height
	s.radial_segments = 12
	return mesh(parent,s,pos,color)

static func collision(parent: Node3D, pos: Vector3, shape: Shape3D, size: Vector3 = Vector3.ONE) -> StaticBody3D:
	var body = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = pos
	var col = CollisionShape3D.new()
	if shape is BoxShape3D: shape.size = size
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)
	return body

static func rod(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: String) -> MeshInstance3D:
	var n = cylinder(parent,(a+b)*0.5,radius,a.distance_to(b),color)
	var direction = (b-a).normalized()
	if absf(direction.dot(Vector3.UP)) < 0.999:
		n.quaternion = Quaternion(Vector3.UP,direction)
	return n

static func tube(parent: Node3D, points: Array, radius: float, color: String) -> void:
	for i in range(points.size()-1): rod(parent,points[i],points[i+1],radius,color)

static func label(parent: Node3D, text: String, pos: Vector3, size: int = 28, color: String = "fff5dd") -> Label3D:
	var l = Label3D.new()
	l.text = text
	l.position = pos
	l.font_size = size
	l.pixel_size = 0.009
	l.modulate = Color(color)
	l.outline_modulate = Color("4b5948")
	l.outline_size = 5
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = false
	parent.add_child(l)
	return l

static func tree(parent: Node3D, pos: Vector3, size: float = 1.0, color: String = "7d9d69", solid: bool = true) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	parent.add_child(root)
	cylinder(root,Vector3(0,1.9*size,0),0.38*size,3.8*size,"916d50",0.22*size)
	for j in range(3):
		var angle = j*TAU/3.0
		rod(root,Vector3(0,2.1*size,0),Vector3(cos(angle)*size,3.4*size,sin(angle)*size),0.16*size,"916d50")
	for i in range(5):
		var angle = i*TAU/5.0
		ball(root,Vector3(cos(angle)*0.85,3.9+float(i%2)*0.5,sin(angle)*0.85)*size,Vector3(2.8,2.3,2.6)*size,color)
	ball(root,Vector3(0,4.9,0)*size,Vector3(2.9,2.1,2.6)*size,color)
	if solid:
		var c = CylinderShape3D.new()
		c.radius = 0.42*size
		c.height = 3.5*size
		collision(root,Vector3(0,1.75*size,0),c)
	return root

static func flower(parent: Node3D, pos: Vector3, color: String, scale_value: float = 1.0) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE*scale_value
	parent.add_child(root)
	rod(root,Vector3.ZERO,Vector3(0,0.55,0),0.025,"74955a")
	ball(root,Vector3(0.09,0.23,0),Vector3(0.27,0.08,0.12),"8da964")
	for j in range(5):
		var a = j*TAU/5
		ball(root,Vector3(cos(a)*0.12,0.57,sin(a)*0.12),Vector3(0.19,0.10,0.19),color)
	ball(root,Vector3(0,0.62,0),Vector3(0.13,0.10,0.13),"efd589")
	return root

static func bench(parent: Node3D, pos: Vector3, angle: float = 0) -> Node3D:
	var root = Node3D.new()
	parent.add_child(root)
	root.position = pos
	root.rotation.y = angle
	box(root,Vector3(0,0.55,0),Vector3(1.8,0.15,0.55),"a58060",true)
	box(root,Vector3(0,0.95,-0.24),Vector3(1.8,0.5,0.12),"b3926d")
	for x in [-0.65,0.65]: box(root,Vector3(x,0.27,0),Vector3(0.12,0.55,0.4),"6c7357")
	return root

static func lantern(parent: Node3D, pos: Vector3) -> void:
	cylinder(parent,pos+Vector3(0,1.2,0),0.055,2.4,"7a6855")
	box(parent,pos+Vector3(0,2.45,0),Vector3(0.38,0.5,0.38),"ebc981")
	cylinder(parent,pos+Vector3(0,2.77,0),0.31,0.2,"796c58",0.03)
