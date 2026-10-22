class_name CozyCompanion
extends CharacterBody3D
const V = preload("res://scripts/character_visual.gd")
var player: CozyPlayer
var visual: CharacterVisual
var breadcrumbs: Array[Vector3] = []
var enabled = false
var waiting = false
var interaction: CozyInteractable
var stuck = 0.0
var previous = Vector3.ZERO

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = 0.35
	var col = CollisionShape3D.new()
	var cap = CapsuleShape3D.new()
	cap.radius = 0.25
	cap.height = 1.6
	col.shape = cap
	col.position.y = 0.82
	add_child(col)
	visual = V.new()
	visual.kind = "swan"
	add_child(visual)
	interaction = CozyInteractable.new()
	interaction.kind = "swan"
	interaction.id = "swan"
	interaction.title = "Swan"
	add_child(interaction)

func _physics_process(delta: float) -> void:
	if not enabled or not is_instance_valid(player): return
	# Follow the exact walkable route taken by Mnki rather than cutting through props.
	if breadcrumbs.is_empty() or breadcrumbs.back().distance_to(player.global_position) > 0.65:
		breadcrumbs.append(player.global_position)
	if breadcrumbs.size() > 90: breadcrumbs.pop_front()
	var distance = global_position.distance_to(player.global_position)
	var target = global_position
	if not waiting and distance > 2.15 and not breadcrumbs.is_empty():
		while breadcrumbs.size()>1 and global_position.distance_to(breadcrumbs.front()) < 0.7: breadcrumbs.pop_front()
		target = breadcrumbs.front()
	else:
		while breadcrumbs.size()>4: breadcrumbs.pop_front()
	var dir = target-global_position
	dir.y = 0
	var speed_value = 6.7 if distance > 7 else 4.6
	velocity.x = move_toward(velocity.x,dir.normalized().x*speed_value if dir.length()>0.2 else 0.0,delta*14)
	velocity.z = move_toward(velocity.z,dir.normalized().z*speed_value if dir.length()>0.2 else 0.0,delta*14)
	if not is_on_floor(): velocity.y -= 18*delta
	else: velocity.y = -0.1
	move_and_slide()
	var walking = Vector2(velocity.x,velocity.z).length()
	if walking > 0.2: visual.rotation.y = lerp_angle(visual.rotation.y,atan2(velocity.x,velocity.z),delta*8)
	elif waiting: visual.rotation.y = lerp_angle(visual.rotation.y,atan2(player.position.x-position.x,player.position.z-position.z),delta*2)
	visual.animate(delta,walking)
	if global_position.distance_to(previous) < 0.01 and distance > 4 and not waiting: stuck += delta
	else: stuck = 0.0
	if stuck > 2 and breadcrumbs.size()>1:
		breadcrumbs.pop_front()
		stuck = 0
	# Only recover far behind the view; no visible pop into the camera foreground.
	if (distance > 32 or position.y < -8) and not player.camera.is_position_in_frustum(global_position+Vector3.UP):
		warp(player.global_position+Vector3(-1.5,0,1.4))
	previous = global_position

func warp(pos: Vector3) -> void:
	global_position = pos
	velocity = Vector3.ZERO
	breadcrumbs.clear()
