extends Node3D

@onready var label_3d = $Label3D
@export var prompt_offset = Vector3(0, 2, 0) # 2 units above the object

func _ready():
	# Ensure Label3D node exists
	if not label_3d:
		print("Creating Label3D node for ", name)
		label_3d = Label3D.new()
		add_child(label_3d)
	
	# Register with the floating prompt system for initialization
	await get_tree().process_frame # Wait for systems to initialize
	var prompt_system = get_tree().get_first_node_in_group("floating_prompt_system")
	if prompt_system:
		print("FloatingPromptComponent registering with system")
		prompt_system.setup_prompt(self)
	else:
		push_error("FloatingPromptComponent: FloatingPromptSystem not found!")
