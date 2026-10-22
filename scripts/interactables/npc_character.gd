class_name NpcCharacter
extends Interactable
## Villager NPC. Separate concerns per GDD §6: ScheduleState (where it intends to be by time),
## ActivityState (walk/idle), DialogueState (QuestSystem + idle lines) and SafetyState
## (if stuck, it gives up and snaps to its schedule point while off-camera).

var npc_id := ""
var model: CharModel
var schedule: Array = []     # [[hour, Vector3 world pos], ...] sorted by hour
var _body: AnimatableBody3D
var _target := Vector3.ZERO
var _talking := 0.0
var _idle_index := 0
var _stuck_t := 0.0
var _last_pos := Vector3.ZERO
var _bubble: Label3D
var _bubble_t := 0.0


func setup(id: String, sched: Array) -> NpcCharacter:
	npc_id = id
	object_id = "npc_" + id
	schedule = sched
	return self


func _ready() -> void:
	marker_height = 2.0
	interaction_range = 2.6
	priority = 3
	super._ready()
	model = VillagerModel.new().setup(NpcDB.get_def(npc_id))
	add_child(model)
	_body = AnimatableBody3D.new()
	_body.collision_layer = 8
	_body.collision_mask = 0
	_body.sync_to_physics = false
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.4
	cs.shape = cap
	cs.position.y = 0.7
	_body.add_child(cs)
	add_child(_body)
	var nm := EnvKit.label3d(self, NpcDB.display_name(npc_id), Vector3(0, 1.85, 0), 34, Color("173b31"), true)
	nm.no_depth_test = false
	nm.modulate.a = 0.85
	_bubble = EnvKit.label3d(self, "", Vector3(0, 2.25, 0), 30, Color("3b2a1e"), true)
	_bubble.visible = false
	_bubble.width = 600
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target = _schedule_point()
	global_position = _target
	TimeManager.hour_changed.connect(func(_h): _target = _schedule_point())


func _schedule_point() -> Vector3:
	if schedule.is_empty():
		return global_position
	var h := TimeManager.hour()
	var pt: Vector3 = schedule[-1][1]
	for e in schedule:
		if h >= int(e[0]):
			pt = e[1]
	return pt


func get_interaction_prompt(_actor: Node) -> String:
	var nm := NpcDB.display_name(npc_id)
	if GameState.quests.available_from(npc_id) != "":
		return "Talk to %s  (has a request)" % nm
	return "Talk to %s" % nm


func interact(actor: Node) -> void:
	_talking = 999.0
	if actor is Node3D:
		_face((actor as Node3D).global_position)
	model.play_action("wave", 0.8)
	var res := GameState.quests.handle_talk(npc_id)
	var lines: Array = res.lines
	var offer: String = res.offer
	if offer != "":
		var on_choice := func(choice: int):
			_talking = 1.0
			if choice == 0:
				GameState.quests.start(offer)
			else:
				GameState.request_dialogue(["%s: Whenever you have time." % NpcDB.display_name(npc_id)])
		GameState.request_dialogue(lines, ["Of course!", "Maybe later"], on_choice)
		return
	if lines.is_empty():
		lines = [_idle_line()]
	var done := func(_c): _talking = 1.0
	GameState.request_dialogue(lines, [], done)


func _idle_line() -> String:
	var def := NpcDB.get_def(npc_id)
	var idle: Array = def.get("idle", ["Hello!"])
	var flags_line := _flag_line()
	if flags_line != "" and _idle_index % 2 == 0:
		_idle_index += 1
		return "%s: %s" % [NpcDB.display_name(npc_id), flags_line]
	var l := String(idle[_idle_index % idle.size()])
	_idle_index += 1
	return "%s: %s" % [NpcDB.display_name(npc_id), l]


## Lines that react to visible world progress (GDD Pillar C).
func _flag_line() -> String:
	var w := GameState.world
	if w.has_flag("festival"):
		return "The lanterns in the park... it feels like the whole village is smiling."
	if w.has_flag("bridge_restored") and npc_id in ["mira", "pip", "bao"]:
		return "The old bridge is back! I visited the orchard twice already."
	if w.has_flag("park_restored") and npc_id in ["elder", "rosa", "ivo", "tamsin"]:
		return "Did you see the new flower bed in the park? That was you two."
	if GameState.shop.level >= 1 and npc_id == "tamsin":
		return "Your stall looks wonderful. Customers keep asking about the order board."
	return ""


func say(text: String, dur: float = 3.0) -> void:
	_bubble.text = text
	_bubble.visible = true
	_bubble_t = dur


func _face(p: Vector3) -> void:
	var d := p - global_position
	if d.length() > 0.1:
		model.rotation.y = atan2(d.x, d.z)


func _physics_process(delta: float) -> void:
	if _bubble_t > 0.0:
		_bubble_t -= delta
		if _bubble_t <= 0.0:
			_bubble.visible = false
	if _talking > 0.0:
		if not GameState.is_ui_blocking():
			_talking -= delta
		model.set_locomotion(0, 1, true)
		return
	var to := _target - global_position
	to.y = 0
	if to.length() < 0.3:
		model.set_locomotion(0, 1, true)
		_stuck_t = 0.0
		return
	var spd := 1.6
	global_position += to.normalized() * min(spd * delta, to.length())
	model.rotation.y = lerp_angle(model.rotation.y, atan2(to.x, to.z), 0.12)
	model.set_locomotion(spd, 3.0, true)
	# SafetyState: if no progress for a while, recover to the destination.
	if global_position.distance_to(_last_pos) < 0.01:
		_stuck_t += delta
		if _stuck_t > 4.0:
			push_warning("NPC %s recovered to schedule point" % npc_id)
			global_position = _target
			_stuck_t = 0.0
	_last_pos = global_position
