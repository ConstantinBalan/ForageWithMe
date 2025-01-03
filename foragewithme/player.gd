extends CharacterBody3D


const SPEED = 5.0
const SPRINT_SPEED = 20.0  # Maximum sprint speed
const JUMP_VELOCITY = 4.5
var player_speed = SPEED

func _ready():
	player_speed = clampf(SPEED, 5.0, 10.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * -0.04))
		
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
func _physics_process(delta):
	print(player_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	 # Handle sprinting - set the target speed based on sprint input
	if Input.is_action_pressed("Sprint") and is_on_floor():
		player_speed = move_toward(player_speed, SPRINT_SPEED, delta * 10)
	else:
		# Return to walking speed when not sprinting
		player_speed = move_toward(player_speed, SPEED, delta * 10)
	
		

	#Input.get_action_strength() for fine tuned movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Move Backward", "Move Forward", "Move Left", "Move Right")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)

	move_and_slide()
