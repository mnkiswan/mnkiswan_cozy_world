class_name CozyWorld
extends Node3D
const S = preload("res://scripts/shapes.gd")
const D = preload("res://scripts/game_data.gd")
const I = preload("res://scripts/interactable.gd")
var rng = RandomNumberGenerator.new()
var sun: DirectionalLight3D
var environment: WorldEnvironment
var decorations: Node3D
var improvements: Node3D
var stall_display: Node3D
var flag_signature = ""
var decor_signature = ""
var stalls_signature = ""
var npcs: Array = []
var water_material: ShaderMaterial

func _ready() -> void:
	rng.seed = 4732
	lighting()
	terrain()
	paths()
	forest()
	pond()
	berry_maze()
	garden()
	paddy()
	orchard()
	farm()
	gate()
	park()
	treehouse(Vector3(-14,0,14),"Our Treehouse","ab7758",true)
	colonies()
	market()
	interior()
	for n in D.NPCS: villager(n)
	decorations = Node3D.new()
	decorations.name = "HomeDecorations"
	add_child(decorations)
	improvements = Node3D.new()
	improvements.name = "VillageImprovements"
	add_child(improvements)
	stall_display = Node3D.new()
	add_child(stall_display)
	State.changed.connect(func(_message): refresh())
	refresh()

func lighting() -> void:
	environment = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("8fb3bb")
	sky_mat.sky_horizon_color = Color("eee7ce")
	sky_mat.ground_bottom_color = Color("829779")
	sky_mat.ground_horizon_color = Color("eee7ce")
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("c3d9cf")
	e.ambient_light_energy = 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e.tonemap_exposure = 0.85
	e.fog_enabled = true
	e.fog_light_color = Color("d9dfcc")
	e.fog_density = 0.0023
	environment.environment = e
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-35,0)
	sun.light_color = Color("ffe1b0")
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 65
	add_child(sun)
	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-35,145,0)
	fill.light_color = Color("b6d5da")
	fill.light_energy = 0.18
	add_child(fill)

func terrain() -> void:
	S.cylinder(self,Vector3(0,-0.65,8),66,1.25,"8b9d70")
	var floor_shape = CylinderShape3D.new()
	floor_shape.radius = 66
	floor_shape.height = 1.0
	S.collision(self,Vector3(0,-0.49,8),floor_shape)
	S.cylinder(self,Vector3(0,-2.1,8),65.7,2.1,"ac9871",64)
	S.cylinder(self,Vector3(0,-3.5,8),64,1.5,"8c7c5e",60)
	for r in D.REGIONS:
		var p: Vector2 = r.p
		S.cylinder(self,Vector3(p.x,0.013,p.y),8.2,0.025,"a6b783" if r.id not in ["pond","market","paddy"] else "b4b38a")
		var sign = Vector3(p.x-3,0,p.y+6.3)
		S.cylinder(self,sign+Vector3(0,0.55,0),0.055,1.1,"987355")
		S.box(self,sign+Vector3(0,1.12,0),Vector3(2.6,0.62,0.13),"efe0b8")
		S.label(self,r.name,sign+Vector3(0,1.17,0.09),19,"fff5d9")
	for i in range(70):
		var a = rng.randf()*TAU
		var r = rng.randf_range(55,64)
		var p = Vector3(sin(a)*r,0,8+cos(a)*r)
		if i%2==0: S.tree(self,p,rng.randf_range(1.0,1.65),["708e61","819e6a","91a36c"][i%3],false)
		else: S.ball(self,p+Vector3(0,0.3,0),Vector3(1.6,0.8,1.3),"a0a58a")
	for i in range(190):
		var p = Vector3(rng.randf_range(-49,48),0.035,rng.randf_range(-43,51))
		# Decorative flecks stay small and do not collide.
		S.ball(self,p,Vector3(0.1,0.05,0.15),["c4cc9a","b4c48a","d6d4a5"][i%3])

func path(a: Vector2, b: Vector2, width: float = 3.0) -> void:
	var mid = (a+b)*0.5
	var length_value = a.distance_to(b)
	var n = S.box(self,Vector3(mid.x,0.035,mid.y),Vector3(width,0.035,length_value),"d5c49a")
	n.rotation.y = atan2(b.x-a.x,b.y-a.y)
	for p in [a,b]: S.cylinder(self,Vector3(p.x,0.035,p.y),width*0.5,0.035,"d5c49a")

func paths() -> void:
	var edges = [[0,1],[1,2],[0,7],[7,8],[8,3],[3,2],[8,9],[9,12],[12,3],[12,4],[4,5],[5,6],[6,11],[11,10],[10,9],[10,7],[6,9],[4,6],[8,12]]
	for edge in edges: path(D.REGIONS[edge[0]].p,D.REGIONS[edge[1]].p)
	for p in [Vector3(-19,0,6),Vector3(4,0,9),Vector3(19,0,9),Vector3(-24,0,27),Vector3(10,0,34),Vector3(-20,0,-12)]: S.lantern(self,p)

func interact(kind: String, id: String, p: Vector3, item: String = "", title: String = "") -> CozyInteractable:
	var n = I.new()
	n.name = id
	n.kind = kind
	n.id = id
	n.item = item
	n.title = title
	n.position = p
	add_child(n)
	return n

func bush(pos: Vector3, id: String, item: String = "berry") -> void:
	var node = interact("gather",id,pos,item)
	S.ball(node,Vector3(0,0.45,0),Vector3(1.35,0.95,1.2),"70935e")
	S.ball(node,Vector3(0.4,0.39,0),Vector3(0.8,0.7,0.8),"8ba96d")
	node.fruit = Node3D.new()
	node.add_child(node.fruit)
	for i in range(7):
		var a = i*TAU/7
		S.ball(node.fruit,Vector3(cos(a)*0.48,0.65+(i%2)*0.12,sin(a)*0.42),Vector3.ONE*0.18,D.ITEMS[item].color)

func forest() -> void:
	for p in [Vector3(-35,0,-27),Vector3(-25,0,-31),Vector3(-33,0,-19),Vector3(-23,0,-25),Vector3(-37,0,-34)]: S.tree(self,p,1.1,"8ba971")
	bush(Vector3(-27,0,-19),"forest_berry")
	bush(Vector3(-31,0,-28),"forest_berry2")
	for i in range(9): S.flower(self,Vector3(-29+rng.randf_range(-6,6),0,-25+rng.randf_range(-6,6)),"efc386",0.7)
	S.bench(self,Vector3(-34,0,-23),0.5)
	S.label(self,"TREE VILLAGE\nWelcome, Mnki & Swan",Vector3(-28,2.4,-28),26)

func pond() -> void:
	var shader = Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; uniform vec4 tint : source_color = vec4(0.29,0.62,0.64,1.0); void vertex(){ VERTEX.y += sin(VERTEX.x*2.0+TIME)*0.025+cos(VERTEX.z*2.0+TIME*0.7)*0.02; } void fragment(){ float wave = sin(VERTEX.x*2.0+TIME)*sin(VERTEX.z*3.0+TIME); ALBEDO = tint.rgb+wave*0.025; ROUGHNESS = 0.3; }"
	water_material = ShaderMaterial.new()
	water_material.shader = shader
	var lake = S.cylinder(self,Vector3(0,0.09,-32),7,0.09,"6cb2ae")
	lake.scale.z = 0.72
	lake.material_override = water_material
	# Water is a non-traversable pond; the bank and wooden jetty remain broad.
	S.box(self,Vector3(0,0.25,-32),Vector3(10,0.5,5.6),"6cb2ae",true).visible = false
	for i in range(13):
		var a = i*PI/12
		S.ball(self,Vector3(cos(a)*7,0.35,-32-sin(a)*4.5),Vector3(1.8,1.0,1.3),"8a9b90")
	for i in range(6): S.ball(self,Vector3(-1+(i%3)*1.1,2.5+i*0.27,-37.8),Vector3(2.0,4.5,1.8),"8c9d8f")
	for i in range(5):
		var stream = S.box(self,Vector3(-0.9+i*0.45,2.4,-36.7),Vector3(0.5,4.6,0.12),"b2d8cf")
		stream.material_override = water_material
	for i in range(9): S.box(self,Vector3(0,0.19,-24.5-i*0.27),Vector3(2.3,0.17,0.24),"b19770",true)
	for x in [-1.1,1.1]:
		for z in [-24.4,-26.5]: S.cylinder(self,Vector3(x,0.3,z),0.065,0.8,"9a795b")
	interact("fish","fishing_jetty",Vector3(0,0.2,-25.5))
	for i in range(7):
		S.cylinder(self,Vector3(rng.randf_range(-5,5),0.17,rng.randf_range(-34,-29)),0.35,0.03,"92b78b")
	S.bench(self,Vector3(4,0,-24),0.4)

func berry_maze() -> void:
	for z in [-30,-26,-22]:
		for x in [22,25,28,31]:
			if x==25 and z==-26: continue
			bush(Vector3(x,0,z),"berry_%d_%d" % [x,z])
	for i in range(5): S.box(self,Vector3(21.2+i*2.4,0.35,-32),Vector3(2.5,0.7,0.75),"78945f",true)
	S.tree(self,Vector3(32,0,-30),1.0,"9b9e70")

func garden() -> void:
	var colors = ["e6a0ac","e8c77f","b5a0c8","e9dfbd"]
	for i in range(12):
		var p = Vector3(24+(i%4)*2.6,0,-9+floori(i/4.0)*3.3)
		var node = interact("gather","flower_%d" % i,p,"flower")
		S.cylinder(node,Vector3(0,0.03,0),0.65,0.05,"93765c")
		node.fruit = Node3D.new()
		node.add_child(node.fruit)
		for j in range(4): S.flower(node.fruit,Vector3(cos(j*TAU/4)*0.3,0,sin(j*TAU/4)*0.3),colors[i%4],0.85)
	for x in [23,35]: S.rod(self,Vector3(x,0,-5),Vector3(x,2.6,-5),0.09,"a18b65")
	S.rod(self,Vector3(23,2.6,-5),Vector3(35,2.6,-5),0.09,"a18b65")
	S.bench(self,Vector3(32,0,3))

func paddy() -> void:
	for i in range(12):
		var p = Vector3(23+(i%4)*2.7,0.045,16+floori(i/4.0)*2.8)
		var n = interact("plot","plot_%02d" % i,p)
		n.soil = S.box(n,Vector3(0,0.035,0),Vector3(1.85,0.08,1.85),"87674e")
		for j in range(4): S.box(n,Vector3(0,0.08,-0.65+j*0.43),Vector3(1.6,0.035,0.06),"9c7d5b")
	for x in [21.6,24.35,27.05,29.75,32.5]: S.box(self,Vector3(x,0.06,18.8),Vector3(0.30,0.08,8.4),"88b6ac")
	S.box(self,Vector3(34,1.0,22),Vector3(2.7,2,2.5),"b39c74",true)
	S.cylinder(self,Vector3(34,2.3,22),2.2,0.8,"a67c54",0.1)
	S.label(self,"1–5  ·  choose seed",Vector3(27,1.6,23),18)

func orchard() -> void:
	var ids = ["mango","banana","coconut"]
	for i in range(9):
		var p = Vector3(15+(i%3)*5.3,0,34+floori(i/3.0)*5)
		var item: String = ids[i%3]
		var tree = S.tree(self,p,0.85,"91a66b" if item=="mango" else "8aa56b")
		if item == "coconut": tree.scale = Vector3(0.7,1.25,0.7)
		var n = interact("gather","fruit_%d" % i,p+Vector3(0,0,1.25),item)
		n.reach = 3.0
		n.fruit = Node3D.new()
		n.add_child(n.fruit)
		for j in range(4):
			var fruit_pos = Vector3(cos(j*TAU/4)*0.9,1.9+sin(j)*0.3,-1.25+sin(j*TAU/4)*0.9)
			var size = Vector3(0.35,0.46,0.31) if item!="banana" else Vector3(0.18,0.6,0.18)
			S.ball(n.fruit,fruit_pos,size,D.ITEMS[item].color)
		S.box(n,Vector3(0,0.20,0),Vector3(0.7,0.4,0.55),"b6966e")

func animal(id: String, p: Vector3) -> void:
	var n = interact("animal",id,p,"",id.capitalize())
	var chicken = id=="chicken"
	var wool = id=="sheep"
	var c = "f3ead8" if id!="cow" else "e2d9c1"
	S.ball(n,Vector3(0,0.65,0),Vector3(1.3,0.85,0.70) if not chicken else Vector3(0.55,0.55,0.55),c)
	S.ball(n,Vector3(0,0.85,0.51),Vector3(0.56,0.60,0.45) if not chicken else Vector3(0.28,0.28,0.28),c)
	if chicken:
		S.ball(n,Vector3(0,1.05,0.52),Vector3(0.12,0.14,0.17),"c9634b")
		S.cylinder(n,Vector3(0,0.83,0.70),0.08,0.16,"e6b24f",0).rotation.x = PI/2
	elif wool:
		for j in range(10):
			var a=j*TAU/10
			S.ball(n,Vector3(cos(a)*0.5,0.65,sin(a)*0.28),Vector3.ONE*0.47,"efe7d5")
		S.ball(n,Vector3(0,0.80,0.66),Vector3(0.36,0.26,0.16),"a0927d")
	else:
		S.ball(n,Vector3(0.2,0.76,0.1),Vector3(0.5,0.67,0.6),"7e735e")
		S.ball(n,Vector3(0,0.7,0.72),Vector3(0.40,0.24,0.18),"d1a48b")
		for side in [-1,1]: S.cylinder(n,Vector3(side*0.24,1.18,0.49),0.06,0.25,"c4b68f",0)
	for side in [-1,1]:
		S.ball(n,Vector3(side*0.16,0.91,0.70),Vector3.ONE*0.055,"40362c")
		S.ball(n,Vector3(side*0.31,0.97,0.49),Vector3(0.25,0.11,0.15),c)
		for z in [-0.23,0.27]: S.cylinder(n,Vector3(side*0.28,0.24,z),0.075 if not chicken else 0.025,0.47,"9a8061")
	var animal_body = CylinderShape3D.new()
	animal_body.radius = 0.27 if chicken else 0.42
	animal_body.height = 0.85
	S.collision(n,Vector3(0,0.45,0),animal_body)
	S.label(n,id.capitalize(),Vector3(0,1.6,0),19)

func farm() -> void:
	S.box(self,Vector3(-5,1.5,46),Vector3(6,3,3),"ad7055",true)
	S.cylinder(self,Vector3(-5,3.5,46),4,1.4,"7d8c69",0.1)
	S.box(self,Vector3(-5,1.1,44.45),Vector3(1.8,2.2,0.12),"e0bc83")
	S.label(self,"THRONN’S FARM",Vector3(-5,2.8,44.3),22)
	for i in range(11):
		var x = -12+i*1.4
		for z in [34.0,44.0]:
			if z==34 and x>-6 and x<0: continue
			S.box(self,Vector3(x,0.55,z),Vector3(0.12,1.1,0.12),"d0bc90")
			S.box(self,Vector3(x+0.7,0.65,z),Vector3(1.4,0.12,0.12),"d0bc90")
	animal("cow",Vector3(-8,0,39))
	animal("sheep",Vector3(-3,0,40))
	animal("chicken",Vector3(1,0,37))
	S.box(self,Vector3(-9,0.3,42),Vector3(2.0,0.6,0.6),"ad8c65")
	S.tree(self,Vector3(-12,0,39),1.2,"95a16a")

func gate() -> void:
	for i in range(3):
		var x = -34+i*4
		var id: String = ["land","water","forest"][i]
		S.cylinder(self,Vector3(x,0.35,-6),0.95,0.7,"b5b3a0")
		S.ball(self,Vector3(x,1.25,-6),Vector3(1.1,1.6,0.9),"a3ad98")
		S.ball(self,Vector3(x,2.2,-6),Vector3(1.0,0.85,0.85),"b9bdab")
		if i == 0:
			for side in [-1,1]: S.cylinder(self,Vector3(x+side*0.3,2.75,-6),0.12,0.6,"9fa78e",0)
		elif i==1: S.ball(self,Vector3(x,2.2,-5.5),Vector3(0.5,0.23,0.4),"a9bcae")
		else:
			for side in [-1,1]: S.ball(self,Vector3(x+side*0.5,1.4,-6),Vector3(0.7,0.4,0.4),"acb49a")
		for side in [-1,1]: S.ball(self,Vector3(x+side*0.19,2.28,-5.59),Vector3.ONE*0.10,"67795c")
		S.label(self,id.to_upper(),Vector3(x,0.65,-5.05),18)
		interact("guardian",id,Vector3(x,0,-4.5),"",id.capitalize())
	for x in [-36,-23]: S.cylinder(self,Vector3(x,2.2,-10),0.22,4.4,"98856b")
	S.rod(self,Vector3(-36,4.4,-10),Vector3(-23,4.4,-10),0.25,"98856b")

func park() -> void:
	S.tree(self,Vector3(0,0,-6),1.5,"98ae78")
	for p in [Vector3(-4,0,-1),Vector3(4,0,-1)]: S.bench(self,p,PI)
	S.cylinder(self,Vector3(0,0.35,-1),1.6,0.7,"b5b7a0")
	S.cylinder(self,Vector3(0,0.75,-1),1.3,0.12,"8bb9ad")
	S.cylinder(self,Vector3(0,1.1,-1),0.25,0.8,"bfc2ab")
	var board = interact("board","community_board",Vector3(4.5,0,-4))
	S.box(board,Vector3(0,1.4,0),Vector3(2.0,1.35,0.18),"967759")
	S.box(board,Vector3(0,1.4,0.11),Vector3(1.75,1.1,0.03),"e5d7b3")
	for x in [-0.7,0.7]: S.cylinder(board,Vector3(x,0.75,0),0.07,1.5,"967759")
	for i in range(3): S.box(board,Vector3(-0.5+i*0.5,1.4,0.16),Vector3(0.35,0.60,0.015),["efe8d0","eedab8","ead2be"][i])
	S.label(board,"VILLAGE REQUESTS",Vector3(0,2.3,0),20)

func treehouse(pos: Vector3, title: String, color: String, home: bool = false) -> void:
	var r = Node3D.new()
	r.position = pos
	add_child(r)
	S.cylinder(r,Vector3(0,2.8,0),0.82,5.6,"8e6a4c",0.58)
	S.cylinder(r,Vector3(0,1.0,0),3.1,0.3,"ac8b62")
	S.cylinder(r,Vector3(0,2.4,0),2.45,2.7,color)
	S.cylinder(r,Vector3(0,4.7,0),2.7,2.0,"92a571",0.2)
	S.cylinder(r,Vector3(0,3.7,0),2.5,0.20,"e0bf86")
	S.box(r,Vector3(0,1.7,2.42),Vector3(0.9,1.7,0.18),"635344")
	for x in [-1.35,1.35]:
		S.box(r,Vector3(x,2.4,2.10),Vector3(0.72,0.8,0.15),"f1cf8a")
		S.box(r,Vector3(x,2.4,2.21),Vector3(0.06,0.83,0.07),"7c664f")
		S.box(r,Vector3(x,2.4,2.21),Vector3(0.75,0.06,0.07),"7c664f")
	for i in range(5): S.box(r,Vector3(0,0.10+i*0.16,4.15-i*0.42),Vector3(1.5,0.2+i*0.32,0.46),"bda078")
	for i in range(5):
		var a=i*TAU/5
		S.ball(r,Vector3(cos(a)*0.8,5.2,sin(a)*0.8),Vector3(2.6,2.0,2.6),"8ca36d")
	S.label(r,title,Vector3(0,4.0,2.2),22)
	if home: interact("home","our_home",pos+Vector3(0,0.1,4.7))

func colonies() -> void:
	for i in range(3): treehouse(Vector3(-38+i*4.5,0,18+(i%2)*8),["Hazel’s Workshop","Willow House","Fern Cottage"][i],"b9a07f")
	for i in range(3):
		var p = Vector3(-35+i*5,0,43+(i%2)*4)
		treehouse(p,["Canopy Nest","Lantern House","The Lookout"][i],"a2aa89")
		S.lantern(self,p+Vector3(2,0,4))
	for i in range(12): S.box(self,Vector3(-32+i*0.7,0.12,40),Vector3(0.65,0.15,1.6),"b39b74",true)

func stall(pos: Vector3, color: String, title: String) -> void:
	var r=Node3D.new()
	r.position=pos
	add_child(r)
	S.box(r,Vector3(0,0.6,0),Vector3(3,1.2,1.25),"ae8a60",true)
	for x in [-1.45,1.45]:
		for z in [-0.55,0.55]: S.cylinder(r,Vector3(x,1.6,z),0.07,3.2,"9b7955")
	for i in range(7):
		var x=-1.5+i*0.5
		S.box(r,Vector3(x,2.75,0),Vector3(0.5,0.16,2.1),color if i%2==0 else "f0e4c8").rotation.x = -0.1
		S.ball(r,Vector3(x,2.62,1.02),Vector3(0.49,0.35,0.10),color if i%2==0 else "f0e4c8")
	S.box(r,Vector3(0,1.98,0.7),Vector3(2.8,0.5,0.1),"f2e2bc")
	S.label(r,title,Vector3(0,2.01,0.78),19)
	for x in [-0.95,0,0.95]:
		S.box(r,Vector3(x,1.3,0),Vector3(0.75,0.22,0.8),"cfac7b")
		for i in range(4): S.ball(r,Vector3(x+(i%2)*0.25-0.12,1.5,floori(i/2.0)*0.3-0.15),Vector3.ONE*0.24,["d5a14c","b85d64","a9b770"][int(abs(x)*2)%3])

func market() -> void:
	S.cylinder(self,Vector3(9,0.045,15),7.7,0.04,"d2bf97")
	stall(Vector3(8,0,12),"ca795e","MNKI & SWAN · FRESH FRUIT")
	interact("stall","fruit_stall",Vector3(8,0,14.3))
	stall(Vector3(15,0,17),"8caa96","SEEDS & LITTLE TREASURES")
	interact("stall","seed_stall",Vector3(15,0,19.3))
	S.bench(self,Vector3(6,0,20),PI)
	for i in range(7):
		var x=3+i*2.4
		S.rod(self,Vector3(x,3.9,13),Vector3(x+1.0,3.7,13),0.025,"a79770")
		S.cylinder(self,Vector3(x,3.55,13),0.18,0.4,["e8bb75","d59c9d","9aad87"][i%3],0).rotation.z = PI

func villager(info: Dictionary) -> void:
	var p: Vector2 = info.p
	var n = interact("npc",info.id,Vector3(p.x,0,p.y),"",info.name)
	var npc_body = CylinderShape3D.new()
	npc_body.radius = 0.27
	npc_body.height = 1.6
	S.collision(n,Vector3(0,0.8,0),npc_body)
	var visual = Node3D.new()
	n.add_child(visual)
	S.ball(visual,Vector3(0,0.75,0),Vector3(0.65,0.9,0.5),info.color)
	S.ball(visual,Vector3(0,1.42,0),Vector3(0.72,0.72,0.66),"dfb68d")
	S.ball(visual,Vector3(0,1.62,-0.05),Vector3(0.78,0.48,0.66),"76604b")
	S.cylinder(visual,Vector3(0,1.79,0),0.5,0.12,info.color)
	S.cylinder(visual,Vector3(0,1.93,0),0.28,0.3,info.color,0.19)
	for side in [-1,1]:
		S.ball(visual,Vector3(side*0.13,1.44,0.31),Vector3.ONE*0.065,"403528")
		S.ball(visual,Vector3(side*0.34,0.8,0),Vector3(0.22,0.57,0.25),info.color)
		S.ball(visual,Vector3(side*0.35,0.52,0),Vector3.ONE*0.15,"dfb68d")
		S.ball(visual,Vector3(side*0.18,0.18,0.06),Vector3(0.24,0.37,0.35),"685a46")
	S.label(n,info.name,Vector3(0,2.4,0),19)
	npcs.append({"root":n,"visual":visual,"p":n.position,"phase":rng.randf()*TAU})

func interior() -> void:
	var r = Node3D.new()
	r.name = "TreehouseInterior"
	r.position = Vector3(150,0,0)
	add_child(r)
	for y in [0.0,4.0]:
		S.box(r,Vector3(0,y-0.15,0),Vector3(13,0.3,11),"b5946b",true)
		for x in [-6.5,6.5]: S.box(r,Vector3(x,y+1.35,0),Vector3(0.2,2.7,11),"d9c7a3",true)
		S.box(r,Vector3(0,y+1.35,-5.5),Vector3(13,2.7,0.2),"d9c7a3",true)
		for x in [-4,4]:
			S.box(r,Vector3(x,y+1.6,-5.35),Vector3(2,1.4,0.1),"adc9c1")
			S.box(r,Vector3(x,y+1.6,-5.25),Vector3(0.08,1.45,0.08),"987956")
		for z in [-5.2,5.2]: S.box(r,Vector3(0,y+0.3,z),Vector3(13,0.6,0.15),"aa8a64",true)
	for y in [0.0,4.0]:
		var light = OmniLight3D.new()
		light.position = Vector3(0,y+2.0,0)
		light.light_color = Color("ffe1b2")
		light.light_energy = 1.8
		light.omni_range = 10.0
		light.omni_attenuation = 0.7
		r.add_child(light)
		for i in range(19): S.box(r,Vector3(-6.15+i*0.68,y+0.015,0),Vector3(0.015,0.015,10.4),"9a805e")
		S.cylinder(r,Vector3(-3,y+0.035,-0.2),2.0,0.035,"bd9b83").scale.z=0.7
		for x in [-5.8,5.8]:
			S.box(r,Vector3(x,y+1.4,-4.6),Vector3(0.65,2.5,0.12),"b8bb94")
		S.lantern(r,Vector3(5.5,y,-4.5))
	# Cozy living area, upper-floor kitchen and sleeping nook.
	S.box(r,Vector3(-3,0.5,-3),Vector3(3.2,0.9,1.2),"9aaf8d",true)
	S.box(r,Vector3(-3,1.1,-3.5),Vector3(3.2,0.8,0.3),"8d9e7a")
	S.box(r,Vector3(-3,0.38,-0.8),Vector3(1.8,0.75,1.0),"997e5b",true)
	S.box(r,Vector3(4,0.6,-3.5),Vector3(2,1.2,0.8),"b5956c",true)
	S.box(r,Vector3(-3,4.45,-2.5),Vector3(3.4,0.9,2.0),"9b7a57",true)
	S.box(r,Vector3(-3,4.95,-2.5),Vector3(3.3,0.25,1.9),"e9bea5")
	for x in [-4,-2]: S.ball(r,Vector3(x,5.15,-3),Vector3(1.1,0.25,0.7),"f6ead4")
	S.box(r,Vector3(3,4.7,-3.7),Vector3(3.8,1.4,1),"b79771",true)
	S.box(r,Vector3(3,5.45,-3.7),Vector3(3.9,0.12,1.1),"e1d3ad")
	S.cylinder(r,Vector3(2,5.65,-3.7),0.24,0.3,"739797")
	for y in [0.0,4.0]:
		S.label(r,"OUR TREEHOUSE" if y==0 else "A LITTLE ROOM TO DREAM",Vector3(0,y+2.4,-5.2),26)
	interact("home_menu","home_living",Vector3(150,0,0))
	interact("home_menu","home_bed",Vector3(147,4,-0.4))
	interact("upstairs","stairs_up",Vector3(155,0,1.0))
	interact("downstairs","stairs_down",Vector3(155,4,1.0))
	interact("exit","home_exit",Vector3(150,0,4.0))
	S.label(r,"Rest · Storage · Decorate",Vector3(0,1.8,0),22)
	S.label(r,"UPSTAIRS ↑",Vector3(5,1.0,1),20)
	S.label(r,"← VILLAGE",Vector3(0,1.1,4.8),20)

func clear_children(node: Node) -> void:
	for child in node.get_children(): child.free()

func refresh() -> void:
	if not is_instance_valid(decorations): return
	var signature = JSON.stringify(State.data.decor_placed)
	if signature != decor_signature:
		decor_signature = signature
		clear_children(decorations)
		for anchor in State.data.decor_placed:
			var index = int(anchor)
			var pos = Vector3(146.0+(index%5)*2.0,0.03 if index<5 else 4.03,2.2)
			decoration(decorations,State.data.decor_placed[anchor],pos)
	var flags = str(State.data.flags)
	if flags != flag_signature:
		flag_signature = flags
		clear_children(improvements)
		for i in range(npcs.size()):
			var a = i*TAU/npcs.size()
			npcs[i].root.position = Vector3(cos(a)*5,0,-4+sin(a)*5) if "festival" in State.data.flags else npcs[i].p
		if "basket" in State.data.flags:
			S.box(improvements,Vector3(2.5,0.3,-2),Vector3(0.8,0.6,0.7),"c19b6e")
			for i in range(6): S.ball(improvements,Vector3(2.3+(i%3)*0.18,0.65,-2+floori(i/3.0)*0.2),Vector3.ONE*0.2,"bd6876")
		if "park_flowers" in State.data.flags:
			for i in range(22):
				var a=i*TAU/22
				S.flower(improvements,Vector3(cos(a)*3.2,0,-6+sin(a)*3.2),["e8aaae","e5c97f","b8a6c8"][i%3])
		if "picnic" in State.data.flags:
			S.box(improvements,Vector3(5,0.07,-27),Vector3(2.4,0.06,1.8),"d4998c")
			S.cylinder(improvements,Vector3(5,0.16,-27),0.32,0.1,"f2ddaf")
		if "shortcut" in State.data.flags:
			path(Vector2(-26,-6),Vector2(23,-6),2.0)
			S.label(improvements,"THE GUARDIANS’ GARDEN · OPEN",Vector3(-19,1.7,-6),20)
		if "festival" in State.data.flags:
			for i in range(12):
				var a = i*TAU/12
				S.lantern(improvements,Vector3(cos(a)*7,0,-4+sin(a)*7))
	var stall_sig = str(State.data.stall_tier)+":"+str(State.metric("earned")/10)
	if stall_sig != stalls_signature:
		stalls_signature = stall_sig
		clear_children(stall_display)
		for tier in range(int(State.data.stall_tier)):
			S.box(stall_display,Vector3(5.6,0.6+tier*0.7,12),Vector3(1,0.12,1.1),"c3a273")
			for j in range(4): S.ball(stall_display,Vector3(5.35+(j%2)*0.35,0.83+tier*0.7,11.8+floori(j/2.0)*0.35),Vector3.ONE*0.27,["e7b758","c5766b","adba76"][tier])
		if State.metric("earned")>0: S.label(stall_display,"GROWN WITH CARE ♥",Vector3(8,0.65,12.7),18)

func decoration(parent: Node3D, id: String, p: Vector3) -> void:
	match id:
		"rug": S.cylinder(parent,p+Vector3(0,0.025,0),0.85,0.05,"d5a38c").scale.z=0.75
		"lamp": S.lantern(parent,p)
		"plant","flowers":
			S.cylinder(parent,p+Vector3(0,0.22,0),0.25,0.44,"bb8e6b",0.3)
			for i in range(4): S.flower(parent,p+Vector3(cos(i)*0.14,0.43,sin(i)*0.14),"a8b879" if id=="plant" else "d9a3b3")
		"picture":
			S.box(parent,p+Vector3(0,0.9,0),Vector3(0.9,1.2,0.1),"a87d58")
			var plane = QuadMesh.new()
			plane.size=Vector2(0.8,1)
			var n=S.mesh(parent,plane,p+Vector3(0,0.91,0.065),"ffffff")
			var mat=StandardMaterial3D.new()
			mat.albedo_texture=preload("res://assets/portraits/couple.webp")
			mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			n.material_override=mat
		"stool":
			S.cylinder(parent,p+Vector3(0,0.3,0),0.15,0.6,"c4b18b")
			S.ball(parent,p+Vector3(0,0.65,0),Vector3(0.8,0.3,0.8),"d69483")
		"shelf":
			for y in [0.2,0.8,1.4]: S.box(parent,p+Vector3(0,y,0),Vector3(0.9,0.12,0.5),"a6845c")
			for x in [-0.4,0.4]: S.box(parent,p+Vector3(x,0.8,0),Vector3(0.1,1.6,0.5),"a6845c")
		"basket": S.box(parent,p+Vector3(0,0.25,0),Vector3(0.6,0.5,0.5),"c4a171")
		"keepsake":
			S.cylinder(parent,p+Vector3(0,0.5,0),0.25,1,"e1bb68",0)
			S.ball(parent,p+Vector3(0,1.1,0),Vector3.ONE*0.25,"f2d482")
		"kettle":
			S.cylinder(parent,p+Vector3(0,0.3,0),0.5,0.6,"aa8763")
			S.ball(parent,p+Vector3(0,0.8,0),Vector3(0.5,0.4,0.5),"90aaa0")
	S.label(parent,D.DECOR[id].name,p+Vector3(0,1.7,0),16)

func _process(delta: float) -> void:
	if not State.data: return
	var fraction = float(State.data.clock)/720.0
	var night = smoothstep(0.67,0.91,fraction)
	sun.light_energy = lerpf(0.9,0.22,night)
	sun.light_color = Color("ffe1b0").lerp(Color("a6b8dc"),night)
	sun.rotation_degrees.x = lerpf(-48,-12,clampf(fraction,0,1))
	for n in npcs:
		var visual: Node3D = n.visual
		visual.position.y = sin(Time.get_ticks_msec()*0.001+n.phase)*0.025
		# Small bounded social routine, never wandering into interaction lanes.
		visual.rotation.y = sin(float(State.data.clock)*0.008+n.phase)*0.35
