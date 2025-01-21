extends Entity

@onready var character_body = owner # Reference to the CharacterBody3D
@onready var camera_3d = get_node("../CameraHolder/Camera3D") # Adjust path as needed
@onready var inventory_component = $InventoryComponent
@onready var relationship_component = $RelationshipComponent

@onready var movement_system = get_tree().get_first_node_in_group("movement_system")
@onready var input_system = get_tree().get_first_node_in_group("player_input_system")

# Movement constants (exposed for systems to use)
const SPEED = 5.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const FOV_NORMAL = 75.0
const FOV_SPRINT = 85.0
const FOV_LERP_SPEED = 5.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	
	if input_system:
		input_system.sprint_started.connect(_on_sprint_started)
		input_system.sprint_ended.connect(_on_sprint_ended)
		input_system.jump_requested.connect(_on_jump_requested)
	else:
		push_error("PlayerEntity: No input system found!")
	
	if movement_system:
		movement_system.movement_state_changed.connect(_on_movement_state_changed)
	else:
		push_error("PlayerEntity: No movement system found!")

func _on_sprint_started():
	if camera_3d:
		var tween = create_tween()
		tween.tween_property(camera_3d, "fov", FOV_SPRINT, 0.2)

func _on_sprint_ended():
	if camera_3d:
		var tween = create_tween()
		tween.tween_property(camera_3d, "fov", FOV_NORMAL, 0.2)

func _on_jump_requested(_player):
	if movement_system:
		movement_system.jump(self)

func _on_movement_state_changed(_entity, state: String):
	# Handle any visual or audio feedback based on movement state
	pass
