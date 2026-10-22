extends Node3D
const W = preload("res://scripts/world.gd")
const P = preload("res://scripts/player.gd")
const C = preload("res://scripts/companion.gd")
const UI = preload("res://scripts/ui.gd")
const D = preload("res://scripts/game_data.gd")
var world: CozyWorld
var player: CozyPlayer
var swan: CozyCompanion
var ui: CanvasLayer
var title_camera: Camera3D
var playing = false
var menu_open = true
var target: CozyInteractable
var region_id = "forest"
var region: Dictionary
var scan_time = 0.0
var autosave = 0.0
var fishing = false
var fishing_clock = 0.0
var bite_at = 3.4
var bite_played = false
var interaction_cooldown = 0.0
var waypoint = ""
var last_milestone = -100.0
var save_clock = 0.0
var photo_mode = false
var fishing_visual: Node3D
var bobber: Node3D

func _ready() -> void:
	setup_input()
	world = W.new()
	add_child(world)
	player = P.new()
	player.position = Vector3(-29,0.1,-21)
	add_child(player)
	swan = C.new()
	swan.player = player
	swan.position = Vector3(-30.5,0.1,-20)
	add_child(swan)
	title_camera = Camera3D.new()
	add_child(title_camera)
	title_camera.position = Vector3(32,24,41)
	title_camera.look_at(Vector3(-1,0,7))
	title_camera.current = true
	region = D.REGIONS[0]
	ui = UI.new()
	ui.game = self
	add_child(ui)
	State.changed.connect(on_changed)
	State.milestone.connect(on_milestone)
	get_tree().auto_accept_quit = false
	if State.settings.fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if "--smoke" in OS.get_cmdline_user_args(): call_deferred("smoke")
	if "--screenshot" in OS.get_cmdline_user_args(): call_deferred("capture_title")
	if "--gallery" in OS.get_cmdline_user_args(): call_deferred("capture_gallery")

func setup_input() -> void:
	var keys = {"move_forward":[KEY_W,KEY_UP],"move_back":[KEY_S,KEY_DOWN],"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"run":[KEY_SHIFT],"jump":[KEY_SPACE],"interact":[KEY_E],"inventory":[KEY_I,KEY_TAB],"journal":[KEY_J],"map":[KEY_M],"pause":[KEY_ESCAPE],"save":[KEY_F5],"photo":[KEY_F2]}
	for action in keys:
		InputMap.add_action(action)
		for key in keys[action]:
			var event = InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action,event)
	var config = ConfigFile.new()
	if config.load("user://bindings.cfg") == OK:
		for action in keys:
			var saved: Variant = config.get_value("keys",action,null)
			if saved is int:
				InputMap.action_erase_events(action)
				var event = InputEventKey.new()
				event.physical_keycode = saved
				InputMap.action_add_event(action,event)

func begin(load_existing: bool = false) -> void:
	if load_existing:
		if not State.load_game(): return
	else:
		State.reset()
		# A new game never overwrites a previous world before explicit confirmation in UI.
	var p: Array = State.data.position
	player.warp(Vector3(p[0],p[1]+0.08,p[2]))
	swan.warp(player.position+Vector3(-1.6,0,1.3))
	player.yaw = 0.0
	player.pitch = -0.38
	player.visual.rotation.y = PI
	player.active = true
	swan.enabled = true
	player.camera.current = true
	playing = true
	world.refresh()
	ui.show_hud()
	set_menu(false)
	ui.toast("Swan · “There’s no hurry. Let’s make ourselves at home.”")
	State.discover("home" if State.data.interior else "forest")

func set_menu(open: bool) -> void:
	menu_open = open
	player.frozen = open or fishing
	swan.waiting = open or fishing
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not playing: return
	if event.is_action_pressed("pause"):
		if fishing: cancel_fishing()
		elif menu_open: ui.close_modal()
		else: ui.open_menu("pause")
		get_viewport().set_input_as_handled()
		return
	if menu_open: return
	if event.is_action_pressed("photo"):
		photo_mode = not photo_mode
		ui.hud.visible = not photo_mode
		ui.toast("F2 · return to the village interface" if photo_mode else "")
	if event.is_action_pressed("save"): save_world()
	if event.is_action_pressed("inventory"): ui.open_menu("inventory")
	if event.is_action_pressed("journal"): ui.open_menu("journal")
	if event.is_action_pressed("map"): ui.open_menu("map")
	if event is InputEventKey and event.pressed and not event.echo:
		var index = event.physical_keycode-KEY_1
		if index >= 0 and index < 5:
			State.selected_crop = D.CROPS.keys()[index]
			ui.toast("Selected seed · "+D.CROPS[State.selected_crop].name)
	if event.is_action_pressed("interact"):
		if fishing: reel()
		elif interaction_cooldown <= 0 and is_instance_valid(target):
			interaction_cooldown = 0.32
			perform(target)
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT and fishing: cancel_fishing()

func _process(delta: float) -> void:
	if not playing: return
	interaction_cooldown = maxf(0,interaction_cooldown-delta)
	if not menu_open:
		State.tick(delta)
		scan_time += delta
		autosave += delta
		if autosave >= 90:
			save_world()
			autosave = 0
		if fishing:
			fishing_clock += delta
			if is_instance_valid(bobber): bobber.position.y = 0.24+sin(fishing_clock*(10 if bite_played else 2))*0.055
			var window = 4.5 if State.settings.easy_fishing else 2.2
			if fishing_clock >= bite_at and not bite_played:
				bite_played = true
				Sound.play("bite")
			if fishing_clock > bite_at+window:
				cancel_fishing()
				ui.toast("It slipped away. No worries — there’s always another fish.")
		if scan_time >= 0.15:
			scan_time = 0
			scan()
			locate_region()
	ui.update_hud()

func scan() -> void:
	if is_instance_valid(target): target.ring.visible = false
	target = null
	var best = 10000.0
	for n in get_tree().get_nodes_in_group("interactables"):
		var point: Vector3 = n.global_position
		var distance = player.global_position.distance_to(point)
		if distance > n.reach or absf(point.y-player.position.y) > 2: continue
		var from = player.global_position+Vector3(0,0.9,0)
		var to = point+Vector3(0,0.9,0)
		var ray = PhysicsRayQueryParameters3D.create(from,to,1)
		var hit = get_world_3d().direct_space_state.intersect_ray(ray)
		if not hit.is_empty() and hit.position.distance_to(to)>0.6: continue
		var score = distance-n.priority
		if not n.available(): score += 2.0
		if n.kind=="swan": score += 0.9
		if score < best:
			best = score
			target = n
	if is_instance_valid(target) and not fishing: target.ring.visible = true

func locate_region() -> void:
	if State.data.interior:
		region = D.REGIONS[9]
	else:
		var best = 100000.0
		for r in D.REGIONS:
			var distance = Vector2(player.position.x,player.position.z).distance_squared_to(r.p)
			if distance < best:
				best = distance
				region = r
	if region.id != region_id:
		region_id = region.id
		if State.discover(region_id): ui.region_banner(region.name,region.subtitle)

func perform(n: CozyInteractable) -> void:
	if player.global_position.distance_to(n.global_position) > n.reach or menu_open: return
	match n.kind:
		"gather":
			if State.gather(n.id,n.item):
				Sound.play("pick")
				player.visual.reaction = 0.5
		"plot":
			if not State.data.plots.has(n.id): State.plant(n.id,State.selected_crop)
			elif not State.data.plots[n.id].watered: State.water(n.id)
			elif not State.harvest(n.id): ui.toast(n.prompt()+" · water and time are all it needs.")
			Sound.play("pick")
		"fish": start_fishing()
		"npc":
			for info in D.NPCS:
				if info.id==n.id: ui.dialogue(info.name,info.line)
		"swan": ui.dialogue("Swan",swan_line(),"swan")
		"animal": ui.animal_menu(n.id)
		"guardian":
			State.guardian(n.id)
			var lines = {"land":"Land holds the roots. Care for the fields, and the village will always have enough.","water":"Water carries patience. Listen at the pond; good things cannot always be hurried.","forest":"Forest shelters us all. Share what grows, and leave room for something new."}
			ui.dialogue(n.title+" Guardian",lines[n.id]+"\n\nThree acts of care open a path. Return to the village board when all three are remembered.")
		"stall": ui.open_menu("shop")
		"board": ui.open_menu("board")
		"home": enter_home()
		"home_menu": ui.open_menu("home")
		"exit": exit_home()
		"upstairs":
			player.warp(Vector3(154,4.12,0))
			swan.warp(Vector3(152,4.12,0))
		"downstairs":
			player.warp(Vector3(154,0.12,0))
			swan.warp(Vector3(152,0.12,0))

func enter_home() -> void:
	State.data.interior = true
	player.warp(Vector3(150,0.12,2))
	swan.warp(Vector3(148.4,0.12,2))
	player.arm.spring_length = 4.0
	ui.toast("Our treehouse · Rest, keep treasures, and make it ours.")

func exit_home() -> void:
	State.data.interior = false
	player.warp(Vector3(-14,0.15,20))
	swan.warp(Vector3(-15.5,0.15,20))
	player.arm.spring_length = 6.3

func swan_line() -> String:
	if "festival" in State.data.flags: return "We made this place a little better than we found it. I think that’s something worth celebrating."
	if State.data.interior: return "A lantern, a little fern, a place for our memories. There’s no right way to make a home — only our way."
	match region_id:
		"pond": return "Listen. The water sounds different when the wind turns. I’ll wait beside you while you fish."
		"farm": return "Let them come to us. Sometimes being gentle is the most useful thing we can do."
		"market": return "Our own little stall. We could sell what we’ve gathered, or keep something aside for a neighbor."
		"paddy": return "We can water these now, then take a walk. There’s no need to stand here watching them grow."
	return "The market feels a little sleepy today. Shall we bring something fresh for the neighbors? There’s a request board in Village Park."

func start_fishing() -> void:
	if fishing: return
	if State.used() >= State.CAPACITY:
		ui.toast("Make a little room in your bag before casting.")
		return
	fishing = true
	fishing_clock = 0
	bite_at = 3.0+fmod(State.metric("caught")*0.73,2.0)
	bite_played = false
	player.frozen = true
	swan.waiting = true
	player.visual.reaction = 0.9
	player.visual.rotation.y = PI
	fishing_visual = Node3D.new()
	add_child(fishing_visual)
	var s = preload("res://scripts/shapes.gd")
	var hand = player.global_position+Vector3(0.3,1.0,0)
	var tip = player.global_position+Vector3(0.3,2.4,-2.8)
	s.rod(fishing_visual,hand,tip,0.025,"a68b60")
	s.rod(fishing_visual,tip,Vector3(0,0.3,-29.4),0.008,"efe8d3")
	bobber = Node3D.new()
	bobber.position = Vector3(0,0.24,-29.4)
	fishing_visual.add_child(bobber)
	s.ball(bobber,Vector3.ZERO,Vector3(0.15,0.18,0.15),"d3745b")
	s.ball(bobber,Vector3(0,0.06,0),Vector3(0.13,0.08,0.13),"f5e9cd")
	ui.toast("A quiet moment · wait for the golden bite cue, then press E.")

func reel() -> void:
	if not fishing: return
	if fishing_clock < bite_at:
		ui.toast("A little patience. Wait for the golden ring.")
		return
	if State.catch_fish(): Sound.play("pick")
	cancel_fishing()

func cancel_fishing() -> void:
	if is_instance_valid(fishing_visual): fishing_visual.queue_free()
	fishing = false
	player.frozen = menu_open
	swan.waiting = menu_open

func save_world() -> bool:
	State.data.position = [player.position.x,player.position.y,player.position.z]
	var success = State.save_game()
	if success: Sound.play("save")
	return success

func on_changed(message: String) -> void:
	if is_instance_valid(ui) and not message.is_empty(): ui.toast(message)

func on_milestone(id: String) -> void:
	player.visual.reaction = 1.2
	swan.visual.reaction = 1.2
	Sound.play("sale" if id=="sale" else "quest")
	if id in ["sale","fish","upgrade"] and Time.get_ticks_msec()*0.001-last_milestone > 35:
		last_milestone = Time.get_ticks_msec()*0.001
		ui.toast({"sale":"Swan · “Our first little earnings. We did this together.”","fish":"Swan · “You caught one! Shall we remember this spot?”","upgrade":"Swan · “Look at our stall! There’s room for so much more now.”"}[id])
	if id=="together": ui.dialogue("A world worth returning to","The lanterns are lit. The gardens are growing. The neighbors have gathered beneath the old tree.\n\nMnki · “We made this place a little better than we found it.”\nSwan · “And there’s still tomorrow.”\n\nYour village is yours to keep exploring. Thank you for making it a home.","couple")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if playing and not save_world():
			ui.dialogue("Your world could not be saved","Please check disk space and try saving again. Your previous save is safe.")
			return
		quit_cleanly()

func quit_cleanly() -> void:
	Sound.shutdown()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func smoke() -> void:
	State.save_path = "user://smoke_only.json"
	begin(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(get_tree().get_nodes_in_group("interactables").size()>65)
	assert(world.npcs.size()==8)
	for r in D.REGIONS:
		player.warp(Vector3(r.p.x,0.2,r.p.y+3))
		locate_region()
		scan()
		await get_tree().physics_frame
	assert(State.data.visited.size()==13)
	enter_home()
	await get_tree().physics_frame
	ui.open_menu("inventory")
	ui.open_menu("journal")
	ui.open_menu("map")
	ui.open_menu("shop")
	ui.open_menu("home")
	ui.open_menu("settings")
	ui.close_modal()
	exit_home()
	assert(save_world())
	assert(State.load_game())
	Sound.shutdown()
	await get_tree().create_timer(0.15).timeout
	print("SMOKE PASS: world, 13 regions, 8 NPCs, home, all UI screens, save/load")
	get_tree().quit()

func capture_title() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(3).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-title.png")
	begin(false)
	player.yaw = 0.5
	await get_tree().create_timer(3).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-game.png")
	await quit_cleanly()

func capture_gallery() -> void:
	State.save_path="user://gallery_only.json"
	begin(false)
	for info in [["market",Vector3(8,0.2,18),0.2],["farm",Vector3(-4,0.2,35),PI],["pond",Vector3(0,0.35,-24),0.0],["garden",Vector3(29,0.2,0),0.0]]:
		player.warp(info[1])
		swan.warp(player.position+Vector3(-1.3,0,0.8))
		player.yaw=info[2]
		player.pitch=-0.35
		locate_region()
		await get_tree().create_timer(1.5).timeout
		get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-"+info[0]+".png")
	# Front view used specifically to inspect both canonical silhouettes.
	player.warp(Vector3(-29,0.2,-22))
	swan.warp(Vector3(-27.7,0.2,-22))
	player.visual.rotation.y=0
	swan.visual.rotation.y=0
	swan.waiting=true
	player.yaw=0
	player.pitch=-0.18
	await get_tree().create_timer(1.5).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-characters.png")
	ui.open_menu("shop")
	await get_tree().create_timer(0.4).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-shop.png")
	ui.open_menu("map")
	await get_tree().create_timer(0.4).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-map.png")
	enter_home()
	ui.close_modal()
	player.yaw=0.0
	await get_tree().create_timer(1).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/mnkiswan-home.png")
	Sound.shutdown()
	await get_tree().process_frame
	get_tree().quit()
