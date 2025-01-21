extends Node

signal movement_state_changed(entity, state) # state could be "walking", "running", "jumping", etc.

const GRAVITY = -9.8 * 2  # Increased gravity for better game feel

func _ready():
	add_to_group("movement_system")

func process_movement(entity: Node, movement_intent: Vector2, is_sprinting: bool, delta: float):
	var character_body = entity.owner
	if not character_body:
		return
		
	# Get the camera's basis for direction
	var camera = entity.camera_3d
	if not camera:
		return
		
	# Calculate move direction relative to camera
	var input_dir = Vector3.ZERO
	input_dir = Vector3(movement_intent.x, 0, movement_intent.y)
	
	var direction = Vector3.ZERO
	if input_dir != Vector3.ZERO:
		# Get the camera's forward direction (excluding pitch)
		var camera_basis = camera.global_transform.basis
		var camera_flat = Vector2(camera_basis.z.x, camera_basis.z.z).normalized()
		var forward = Vector3(camera_flat.x, 0, camera_flat.y)
		
		# Rotate the input direction by the camera's yaw
		var camera_yaw = atan2(forward.x, forward.z)
		direction = input_dir.rotated(Vector3.UP, camera_yaw)
		direction = direction.normalized()
	
	# Calculate speed based on sprint state
	var current_speed = entity.SPRINT_SPEED if is_sprinting else entity.SPEED
	if not character_body.is_on_floor():
		current_speed = entity.SPEED  # Don't allow sprinting in air
		
	# Store current vertical velocity
	var vertical_velocity = character_body.velocity.y
	
	# Apply horizontal movement
	if direction != Vector3.ZERO:
		character_body.velocity.x = direction.x * current_speed
		character_body.velocity.z = direction.z * current_speed
		movement_state_changed.emit(entity, "running" if is_sprinting else "walking")
	else:
		character_body.velocity.x = move_toward(character_body.velocity.x, 0, current_speed)
		character_body.velocity.z = move_toward(character_body.velocity.z, 0, current_speed)
		movement_state_changed.emit(entity, "idle")
	
	# Apply gravity
	if not character_body.is_on_floor():
		vertical_velocity += GRAVITY * delta
		movement_state_changed.emit(entity, "falling")
	
	# Restore vertical velocity
	character_body.velocity.y = vertical_velocity
	
	character_body.move_and_slide()

func jump(entity: Node):
	var character_body = entity.owner
	if character_body and character_body.is_on_floor():
		character_body.velocity.y = entity.JUMP_VELOCITY
		movement_state_changed.emit(entity, "jumping")
