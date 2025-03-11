extends Character
class_name Player

@onready var camera_holder = $CameraHolder
@onready var camera = $CameraHolder/Camera3D
@onready var interaction_ray = %InteractionRay
@onready var inventory_controller = get_tree().get_first_node_in_group("inventory_controller")

const FOV_NORMAL = 75.0
const FOV_SPRINT = 85.0
const FOV_LERP_SPEED = 5.0
const GRAVITY = -9.8 * 2 # Increased gravity for better game feel
const INTERACTION_DISTANCE = 10.0 # Maximum distance for interaction raycast
const HEAD_HEIGHT = 1.5 # Approximate height for ray origin

var is_sprinting: bool = false
var player_speed = speed
var current_interactable: GameObject = null

func _ready():
	super._ready()
	player_speed = clampf(speed, 5.0, 10.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	
	# Setup interaction raycast
	if !interaction_ray:
		interaction_ray = RayCast3D.new()
		add_child(interaction_ray)
		interaction_ray.name = "InteractionRay"
	
	# Position the ray at head height
	interaction_ray.position.y = HEAD_HEIGHT
	interaction_ray.target_position = Vector3(0, 0, -INTERACTION_DISTANCE)
	interaction_ray.collision_mask = 2 # Layer 2 for interactable objects
	interaction_ray.debug_shape_custom_color = Color.BLUE
	interaction_ray.debug_shape_thickness = 2

func _physics_process(delta):
	# Lock player rotation to initial rotation during orbit mode
	if camera_holder.is_orbiting:
		rotation.y = camera_holder.initial_player_rotation
		
	handle_movement_intent(delta)
	handle_fov(delta)
	update_interaction_ray()
	check_interaction()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func update_interaction_ray() -> void:
	# Make the ray follow camera rotation
	var cam_basis = camera.global_transform.basis
	interaction_ray.global_transform.basis = cam_basis

func handle_movement_intent(delta):
	# Determine target speed based on input
	if is_sprinting and is_on_floor():
		player_speed = move_toward(player_speed, sprint_speed, delta * 10)
	else:
		player_speed = move_toward(player_speed, speed, delta * 10)
	
	# Get input direction and transform it relative to the player's rotation
	var input_dir = Input.get_vector("Move Backward", "Move Forward", "Move Left", "Move Right")
	var direction = Vector3.ZERO
	
	# Only use camera basis for movement when not in orbit mode
	if !camera_holder.is_orbiting:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		# During orbit, use the stored initial rotation for movement
		var basis = Transform3D(Basis.from_euler(Vector3(0, camera_holder.initial_player_rotation, 0)))
		direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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

func check_interaction():
	var collider = interaction_ray.get_collider()
	if collider and collider is GameObject:
		var hover_text = collider.get_hover_text()
		if hover_text.is_empty():
			if current_interactable:
				current_interactable.hide_hover_label()
			current_interactable = null
		elif current_interactable != collider:
			# Hide label of previous interactable
			if current_interactable:
				current_interactable.hide_hover_label()
			# Show label of new interactable
			collider.show_hover_label()
			current_interactable = collider
	else:
		if current_interactable:
			current_interactable.hide_hover_label()
		current_interactable = null

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
	
	# Handle interaction input
	if event.is_action_pressed("Interact") and current_interactable:
		current_interactable.interact_with(self)

func add_item(item_id: String, amount: int = 1) -> bool:
	if inventory_controller:
		return inventory_controller.add_item(item_id)
	return super.add_item(item_id, amount)

func add_item_with_texture(item_id: String, texture: Texture2D) -> bool:
	if inventory_controller:
		return inventory_controller.add_item(item_id, texture)
	return super.add_item(item_id, 1)

func get_inventory() -> Dictionary:
	if inventory_controller:
		return inventory_controller.get_inventory()
	return inventory
