extends Node3D

@onready var label_3d = $Label3D
@export var prompt_offset = Vector3(0, 2, 0) # 2 units above the object

func _ready():
	print("FloatingPromptComponent ready on: ", get_parent().name)
	if not label_3d:
		push_error("FloatingPromptComponent: Label3D node not found!")
		return
		
	# Set initial Label3D properties
	label_3d.billboard = 1 # Always face camera
	label_3d.no_depth_test = true # Always render on top
	label_3d.position = prompt_offset
	label_3d.modulate = Color(1, 1, 1, 1) # Full opacity white
	label_3d.font_size = 24
	label_3d.outline_size = 2 # Make text more readable
	label_3d.pixel_size = 0.01 # Adjust text scale
	label_3d.hide()
	
	# Position this component relative to its parent
	global_transform.origin = get_parent().get_parent().global_transform.origin
	position += prompt_offset
	
func show_prompt(text: String):
	print("Showing 3D prompt with text: ", text)
	if label_3d:
		label_3d.text = text
		label_3d.show()
		print("Label3D should now be visible at position: ", global_transform.origin)
		
func hide_prompt():
	print("Hiding 3D prompt")
	if label_3d:
		label_3d.hide()

func _process(_delta):
	if label_3d and label_3d.visible:
		# Update position if parent moves
		global_transform.origin = get_parent().get_parent().global_transform.origin + prompt_offset
