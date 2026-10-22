class_name CozyPlayer
extends CharacterBody3D
const V = preload("res://scripts/character_visual.gd")
var visual: CharacterVisual
var pivot: Node3D
var arm: SpringArm3D
var camera: Camera3D
var yaw = 0.0
var pitch = -0.38
var active = false
var frozen = false
var last_safe = Vector3(-29,0.1,-21)
var action_timer = 0.0
var speed = 4.4

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.35
	var col = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.29
	capsule.height = 1.65
	col.shape = capsule
	col.position.y = 0.84
	add_child(col)
	visual = V.new()
	add_child(visual)
	pivot = Node3D.new()
	pivot.position.y = 1.38
	add_child(pivot)
	arm = SpringArm3D.new()
	arm.spring_length = 6.3
	arm.margin = 0.25
	arm.collision_mask = 1
	var shape = SphereShape3D.new()
	shape.radius = 0.20
	arm.shape = shape
	pivot.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 58
	camera.near = 0.1
	camera.far = 240
	arm.add_child(camera)
	pivot.rotation = Vector3(pitch,yaw,0)

func _unhandled_input(event: InputEvent) -> void:
	if not active or frozen: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x*State.settings.sensitivity
		pitch -= event.relative.y*State.settings.sensitivity*(-1 if State.settings.invert_y else 1)
		pitch = clampf(pitch,-0.9,0.12)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: arm.spring_length = maxf(3.2,arm.spring_length-0.4)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: arm.spring_length = minf(9,arm.spring_length+0.4)

func _physics_process(delta: float) -> void:
	if not active: return
	pivot.rotation.x = pitch
	pivot.rotation.y = yaw
	var input = Vector2.ZERO if frozen else Input.get_vector("move_left","move_right","move_forward","move_back")
	var direction = (Basis(Vector3.UP,yaw)*Vector3(input.x,0,input.y)).normalized()
	var target_speed = 6.5 if Input.is_action_pressed("run") else speed
	velocity.x = move_toward(velocity.x,direction.x*target_speed,delta*15)
	velocity.z = move_toward(velocity.z,direction.z*target_speed,delta*15)
	if not is_on_floor(): velocity.y -= 18.0*delta
	else:
		if not frozen and Input.is_action_just_pressed("jump"): velocity.y = 6.4
		if position.x > 100 or Vector2(position.x,position.z-8.0).length() < 62:
			last_safe = global_position
	move_and_slide()
	if position.y < -8 or (Vector2(position.x,position.z-8.0).length() > 65 and position.x < 100):
		global_position = last_safe if last_safe.y > -1 else Vector3(0,0.1,4)
		velocity = Vector3.ZERO
	if direction.length() > 0.1: visual.rotation.y = lerp_angle(visual.rotation.y,atan2(direction.x,direction.z),delta*12)
	visual.animate(delta,Vector2(velocity.x,velocity.z).length())

func warp(pos: Vector3) -> void:
	global_position = pos
	last_safe = pos
	velocity = Vector3.ZERO
