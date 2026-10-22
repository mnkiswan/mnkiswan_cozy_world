extends SceneTree
var game: Node
var state: Node
var passed = 0
var failed = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	if ok:
		passed+=1
		print("PASS · "+label)
	else:
		failed+=1
		push_error("FAIL · "+label)

func frames(count: int) -> void:
	for i in count: await physics_frame

func run() -> void:
	state=root.get_node("State")
	state.save_path="user://tests/integration_only.json"
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.begin(false)
	await frames(20)
	check(game.player.is_on_floor(),"player starts on solid ground")
	var start: Vector3=game.player.position
	Input.action_press("move_forward")
	await frames(90)
	Input.action_release("move_forward")
	await frames(20)
	check(game.player.position.distance_to(start)>3,"keyboard input moves CharacterBody3D through world")
	check(game.player.is_on_floor() and game.player.position.y>=-0.1,"movement stays grounded")
	var inventory_before: Dictionary=state.data.inventory.duplicate()
	game.player.position.y=-10
	await frames(3)
	check(game.player.position.y>=0 and state.data.inventory==inventory_before,"fall recovery preserves inventory and returns to safe ground")
	game.player.position=Vector3(80,0.1,8)
	await frames(3)
	check(game.player.position.x<65,"edge recovery returns to an inset safe location")
	game.player.warp(Vector3(-29,0.1,-21))
	game.swan.warp(Vector3(-30,0.1,-19))
	game.swan.breadcrumbs.clear()
	Input.action_press("move_forward")
	await frames(150)
	Input.action_release("move_forward")
	await frames(100)
	check(game.swan.position.distance_to(game.player.position)<5,"Swan follows player route without falling behind")
	check(game.swan.is_on_floor(),"companion respects terrain collision")
	game.player.warp(Vector3(-27,0.12,-17.6))
	game.swan.warp(Vector3(-31,0.1,-19))
	await frames(5)
	game.scan()
	check(is_instance_valid(game.target) and game.target.id=="forest_berry","interaction scanner focuses nearest reachable berry bush")
	if is_instance_valid(game.target): game.perform(game.target)
	check(state.count("berry")==2,"focused world interaction actually awards berries")
	game.perform(game.get_node("CozyWorld/forest_berry") if game.has_node("CozyWorld/forest_berry") else game.target)
	check(state.count("berry")==2,"repeated world interaction cannot duplicate gathering")
	var before=state.total_time()
	game.ui.open_menu("inventory")
	await frames(90)
	check(is_equal_approx(before,state.total_time()),"opening inventory pauses world time")
	check(game.player.frozen and game.swan.waiting,"menus suspend player input and companion route")
	game.ui.close_modal()
	await frames(20)
	check(state.total_time()>before,"closing menu resumes simulation")
	# Camera should retract before a solid wall can cover it.
	game.enter_home()
	await frames(10)
	check(state.data.interior and game.player.position.x>140,"door transitions to real home interior")
	game.player.warp(Vector3(155.4,0.12,0))
	game.player.yaw=PI/2
	game.player.pitch=-0.1
	await frames(10)
	check(game.player.arm.get_hit_length()<game.player.arm.spring_length,"spring arm retracts against interior wall")
	var upstairs: Node
	for n in get_nodes_in_group("interactables"):
		if n.id=="stairs_up": upstairs=n
	game.player.warp(Vector3(154.3,0.12,1))
	game.perform(upstairs)
	await frames(8)
	check(game.player.position.y>3.9 and game.player.is_on_floor(),"upper floor transition lands on solid second storey")
	game.exit_home()
	await frames(5)
	check(not state.data.interior and game.player.position.x<0,"home exit returns safely to village")
	game.player.warp(Vector3(0,0.4,-24.6))
	await frames(5)
	game.start_fishing()
	game.reel()
	check(state.metric("caught")==0 and game.fishing,"early reel gives no fish and preserves active fishing")
	game.fishing_clock=game.bite_at+0.5
	game.reel()
	check(state.metric("caught")==1 and not game.fishing,"bite window catch completes once and releases movement")
	game.reel()
	check(state.metric("caught")==1,"inactive fishing cannot grant repeated fish")
	game.start_fishing()
	game.fishing_clock=game.bite_at+10
	await frames(3)
	check(not game.fishing and not game.player.frozen and state.metric("caught")==1,"missed bite cancels without a reward and restores movement")
	for r in game.D.REGIONS:
		game.player.warp(Vector3(r.p.x,0.2,r.p.y+3))
		game.locate_region()
		await frames(1)
	check(state.data.visited.size()==13,"every named region discovers through world position")
	game.ui.open_menu("journal")
	game.ui.open_menu("map")
	game.ui.open_menu("shop")
	game.ui.open_menu("home")
	game.ui.open_menu("settings")
	game.ui.animal_menu("cow")
	check(is_instance_valid(game.ui.modal),"all major menus construct with populated world state")
	game.ui.close_modal()
	check(game.save_world() and state.load_game(),"world position and system state save/load together")
	state.data.flags.append("festival")
	game.world.refresh()
	check(game.world.npcs.all(func(n): return Vector2(n.root.position.x,n.root.position.z+4).length()<7),"festival visibly gathers all villagers in the park")
	print("WORLD TESTS: %d passed, %d failed" % [passed,failed])
	root.get_node("Sound").shutdown()
	await process_frame
	quit(1 if failed>0 else 0)
