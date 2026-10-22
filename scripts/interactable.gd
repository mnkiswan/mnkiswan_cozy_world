class_name CozyInteractable
extends Node3D
const S = preload("res://scripts/shapes.gd")
const D = preload("res://scripts/game_data.gd")
var id = ""
var kind = "gather"
var item = "berry"
var title = ""
var reach = 2.7
var priority = 0.0
var fruit: Node3D
var crop_visual: Node3D
var soil: MeshInstance3D
var ring: MeshInstance3D
var last_stage = -99
var phase = 0.0

func _ready() -> void:
	add_to_group("interactables")
	var torus = TorusMesh.new()
	torus.inner_radius = 0.40
	torus.outer_radius = 0.46
	torus.rings = 16
	torus.ring_segments = 8
	ring = S.mesh(self,torus,Vector3(0,0.045,0),"f4d58a")
	ring.visible = false

func available() -> bool:
	if kind == "gather": return float(State.data.gathered.get(id,0)) <= State.total_time()
	return true

func prompt() -> String:
	match kind:
		"gather": return "Gather "+D.ITEMS[item].name.to_lower() if available() else "Growing back · a little patience"
		"plot":
			if not State.data.plots.has(id): return "Plant %s · %d seeds" % [D.CROPS[State.selected_crop].name,State.data.seeds.get(State.selected_crop,0)]
			var p: Dictionary = State.data.plots[id]
			if not p.watered: return "Water "+D.CROPS[p.crop].name.to_lower()
			if p.growth >= D.CROPS[p.crop].seconds: return "Harvest "+D.CROPS[p.crop].name.to_lower()
			return "%s growing · %d%%" % [D.CROPS[p.crop].name,100*p.growth/D.CROPS[p.crop].seconds]
		"fish": return "Cast a line · fishing"
		"npc": return "Talk to "+title
		"animal": return "Care for "+title
		"guardian": return "Read the "+title+" guardian plaque"
		"stall": return "Open our fruit stall"
		"board": return "Read village requests"
		"home": return "Enter our treehouse"
		"home_menu": return "Rest, store & decorate"
		"exit": return "Return to the village"
		"upstairs": return "Go upstairs · kitchen & bedroom"
		"downstairs": return "Go downstairs · living room"
		"swan": return "Talk to Swan"
	return title

func _process(delta: float) -> void:
	phase += delta
	if ring.visible: ring.rotation.y += delta
	if kind == "gather" and fruit:
		fruit.visible = available()
		fruit.position.y = sin(phase*1.3)*0.03
	if kind == "plot":
		if soil:
			var watered = State.data.plots.has(id) and State.data.plots[id].watered
			soil.material_override = S.mat("685d48" if watered else "87674e")
		var stage = -1
		if State.data.plots.has(id):
			var p: Dictionary = State.data.plots[id]
			stage = mini(3,int(float(p.growth)/float(D.CROPS[p.crop].seconds)*3.0))
			if not p.watered: stage = 0
		if stage != last_stage:
			last_stage = stage
			if crop_visual: crop_visual.queue_free()
			crop_visual = Node3D.new()
			add_child(crop_visual)
			if stage >= 0:
				var crop: String = State.data.plots[id].crop
				for i in range(5):
					var x = (i%3-1)*0.35
					var z = (i/3.0-0.5)*0.4
					var h = 0.15+stage*0.17
					S.rod(crop_visual,Vector3(x,0.08,z),Vector3(x,h,z),0.035,"6f8f50")
					S.ball(crop_visual,Vector3(x-0.1,h*0.7,z),Vector3(0.3,0.10,0.16),"99b569")
					if stage >= 2: S.ball(crop_visual,Vector3(x,h,z),Vector3.ONE*(0.12+stage*0.04),D.ITEMS[crop].color)
