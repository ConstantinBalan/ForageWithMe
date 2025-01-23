extends Character
class_name Player

@onready var camera_holder = $CameraHolder
@onready var camera = $CameraHolder/Camera3D

const FOV_NORMAL = 75.0
const FOV_SPRINT = 85.0
const FOV_LERP_SPEED = 5.0
const GRAVITY = -9.8 * 2 # Increased gravity for better game feel

var is_sprinting: bool = false
var player_speed = speed

func _ready():
	super._ready()
	player_speed = clampf(speed, 5.0, 10.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _physics_process(delta):
	handle_movement_intent(delta)
	handle_fov(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func handle_movement_intent(delta):
	# Determine target speed based on input
	if is_sprinting and is_on_floor():
		player_speed = move_toward(player_speed, sprint_speed, delta * 10)
	else:
		player_speed = move_toward(player_speed, speed, delta * 10)
	
	# Get input direction and transform it relative to the player's rotation
	var input_dir = Input.get_vector("Move Backward", "Move Forward", "Move Left", "Move Right")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	if direction:
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)

func handle_fov(delta):
	var target_fov = FOV_NORMAL
	if is_sprinting and is_on_floor():
		target_fov = FOV_SPRINT
	camera.fov = lerp(camera.fov, target_fov, FOV_LERP_SPEED * delta)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * -0.04)) # Rotate the player with mouse
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if event.is_action_pressed("Sprint"):
		is_sprinting = true
	elif event.is_action_released("Sprint"):
		is_sprinting = false
