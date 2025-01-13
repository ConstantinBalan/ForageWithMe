extends Entity

@onready var character_body = owner # Reference to the CharacterBody3D
@onready var camera_3d = get_node("../CameraHolder/Camera3D") # Adjust path as needed
@onready var inventory_component = $InventoryComponent
@onready var relationship_component = $RelationshipComponent


@onready var movement_system = get_tree().get_first_node_in_group("movement_system")

const SPEED = 5.0
const SPRINT_SPEED = 20.0
const JUMP_VELOCITY = 4.5
const FOV_NORMAL = 75.0
const FOV_SPRINT = 85.0
const FOV_LERP_SPEED = 5.0

var player_speed = SPEED
var is_sprinting = false

func _ready():
	player_speed = clampf(SPEED, 5.0, 10.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _input(event):
	if event is InputEventMouseMotion:
		owner.rotate_y(deg_to_rad(event.relative.x * -0.04)) # Rotate the CharacterBody3D

	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event.is_action_pressed("ui_accept"):
		jump()

	if event.is_action_pressed("Sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

func _physics_process(delta):
	handle_movement_intent(delta)
	handle_fov(delta)
	movement_system.apply_gravity(owner, delta) # owner is the CharacterBody3D
	owner.move_and_slide()

func handle_movement_intent(delta):
	# Determine target speed based on input
	if is_sprinting and character_body.is_on_floor():
		player_speed = move_toward(player_speed, SPRINT_SPEED, delta * 10)
	else:
		player_speed = move_toward(player_speed, SPEED, delta * 10)

	# Get input direction
	var input_dir = Input.get_vector("Move Backward", "Move Forward", "Move Left", "Move Right")
	var direction = (owner.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print(owner)
	movement_system.apply_movement(owner, direction, player_speed)

	# Apply movement to the CharacterBody3D
	#if direction:
	#	character_body.velocity.x = direction.x * player_speed
	#	character_body.velocity.z = direction.z * player_speed
	#else:
	#	character_body.velocity.x = move_toward(character_body.velocity.x, 0, player_speed)
	#	character_body.velocity.z = move_toward(character_body.velocity.z, 0, player_speed)

func jump():
	if character_body.is_on_floor():
		movement_system.apply_jump(owner, JUMP_VELOCITY)

func handle_fov(delta):
	var target_fov = FOV_NORMAL
	if is_sprinting and character_body.is_on_floor():
		target_fov = FOV_SPRINT
	camera_3d.fov = lerp(camera_3d.fov, target_fov, FOV_LERP_SPEED * delta)
