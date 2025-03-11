extends SpringArm3D

# Camera constraints for vertical rotation
const VERTICAL_LOW = deg_to_rad(-45) # Maximum look-up angle
const VERTICAL_HIGH = deg_to_rad(60) # Maximum look-down angle
const MOUSE_SENSITIVITY = 0.04

# Spring arm configuration
const ARM_HEIGHT = 1.0
const ARM_LENGTH = 4.0
const INITIAL_Y_ROTATION = deg_to_rad(-90) # Camera starts behind player (-90 degrees)

# Transition settings
const TRANSITION_DURATION = 0.5
const TRANSITION_EASE = Tween.EASE_OUT
const TRANSITION_TRANS = Tween.TRANS_CUBIC

# Camera states
var is_orbiting: bool = false
var is_transitioning: bool = false
var vertical_rotation: float = 0.0
var camera_enabled: bool = true # New flag to control camera movement
var initial_player_rotation: float = 0.0 # Store player's initial rotation when orbiting

# Transition state
var transition_weight: float = 0.0
var start_transform: Transform3D
var target_y_rotation: float = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var inventory_controller = get_tree().get_first_node_in_group("inventory_controller")

func _ready():
	# Set up spring arm properties
	spring_length = ARM_LENGTH
	margin = 0.25
	shape = create_shape()
	collision_mask = 1

	# Set initial position and rotation
	position = Vector3(0, ARM_HEIGHT, 0)
	rotation.y = INITIAL_Y_ROTATION
	vertical_rotation = 0.0

	if inventory_controller:
		inventory_controller.inventory_toggled.connect(_on_inventory_toggled)
		print("CameraHolder: Connected to inventory controller")

func create_shape() -> Shape3D:
	var shape = SphereShape3D.new()
	shape.radius = 0.25
	return shape

# Normalize angle to find shortest rotation path
func normalize_angle(angle: float) -> float:
	angle = fmod(angle, PI * 2.0)
	if angle > PI:
		angle -= PI * 2.0
	elif angle < -PI:
		angle += PI * 2.0
	return angle

func _input(event: InputEvent) -> void:
	if !camera_enabled:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and !is_transitioning:
			start_orbit()
		elif !event.pressed and is_orbiting:
			end_orbit()

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_motion(event)

func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# Handle vertical rotation
	var delta_vertical = event.relative.y * MOUSE_SENSITIVITY * 0.01
	vertical_rotation = clamp(
		vertical_rotation - delta_vertical,
		VERTICAL_LOW,
		VERTICAL_HIGH
	)
	rotation.x = vertical_rotation

	# Handle horizontal rotation
	var delta_horizontal = event.relative.x * MOUSE_SENSITIVITY * 0.01
	if is_orbiting:
		# In orbit mode, rotate around the player
		rotation.y -= delta_horizontal
	else:
		# In normal mode, only rotate if not orbiting
		rotation.y -= delta_horizontal

func start_orbit() -> void:
	is_orbiting = true
	is_transitioning = false
	# Store the player's current rotation when starting orbit
	var player = get_tree().get_first_node_in_group("player")
	if player:
		initial_player_rotation = player.rotation.y

func end_orbit() -> void:
	if !is_orbiting:
		return
	is_orbiting = false

	# Reset player rotation to initial state when ending orbit
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.rotation.y = initial_player_rotation

	# Store our current transform
	start_transform = transform

	# Calculate target rotation
	target_y_rotation = INITIAL_Y_ROTATION

	# Start transition
	is_transitioning = true
	transition_weight = 0.0

	var tween = create_tween()
	tween.set_trans(TRANSITION_TRANS)
	tween.set_ease(TRANSITION_EASE)

	# Smoothly interpolate the transition weight
	tween.tween_property(
		self,
		"transition_weight",
		1.0,
		TRANSITION_DURATION
	)

	# Clean up when transition completes
	tween.finished.connect(func():
		is_transitioning = false
		rotation.y = INITIAL_Y_ROTATION
	)

func _on_inventory_toggled(is_open: bool) -> void:
	camera_enabled = !is_open
	if is_open and is_orbiting:
		end_orbit()
	print("Camera enabled: ", camera_enabled)

func _physics_process(_delta: float) -> void:
	if is_transitioning:
		# During transition, only interpolate the Y rotation
		rotation.y = lerp_angle(start_transform.basis.get_euler().y, target_y_rotation, transition_weight)
	elif !is_orbiting:
		# When not orbiting or transitioning, maintain home position
		rotation.y = INITIAL_Y_ROTATION

	# Always maintain correct height
	position.y = lerp(position.y, ARM_HEIGHT, 0.1)
