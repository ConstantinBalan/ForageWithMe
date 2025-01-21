extends Node

# System that manages floating prompts in the game world
signal prompt_shown(entity: Node, text: String)
signal prompt_hidden(entity: Node)

func _ready():
	print("FloatingPromptSystem initialized")
	add_to_group("floating_prompt_system")

func find_root_entity(component: Node) -> Node:
	var current = component
	while current:
		if current is StaticBody3D or current is CharacterBody3D:
			return current
		current = current.get_parent()
	return null

func setup_prompt(prompt_component: Node):
	var label_3d = prompt_component.get_node("Label3D")
	if not label_3d:
		push_error("FloatingPromptSystem: Label3D node not found in ", prompt_component.name)
		return
		
	# Set initial Label3D properties
	label_3d.billboard = 1 # Always face camera
	label_3d.no_depth_test = true # Always render on top
	label_3d.position = prompt_component.prompt_offset
	label_3d.modulate = Color(1, 1, 1, 1) # Full opacity white
	label_3d.font_size = 24
	label_3d.outline_size = 2 # Make text more readable
	label_3d.pixel_size = 0.01 # Adjust text scale
	label_3d.hide()
	
	# Position relative to root entity
	var root_entity = find_root_entity(prompt_component)
	if root_entity:
		prompt_component.global_transform.origin = root_entity.global_transform.origin
		prompt_component.position += prompt_component.prompt_offset
	else:
		push_error("FloatingPromptSystem: Could not find root entity for ", prompt_component.name)

func show_prompt(prompt_component: Node, text: String):
	var label_3d = prompt_component.get_node("Label3D")
	if label_3d:
		label_3d.text = text
		label_3d.show()
		var root_entity = find_root_entity(prompt_component)
		if root_entity:
			emit_signal("prompt_shown", root_entity, text)
	else:
		push_error("FloatingPromptSystem: Label3D not found in ", prompt_component.name)

func hide_prompt(prompt_component: Node):
	var label_3d = prompt_component.get_node("Label3D")
	if label_3d:
		label_3d.hide()
		var root_entity = find_root_entity(prompt_component)
		if root_entity:
			emit_signal("prompt_hidden", root_entity)
	else:
		push_error("FloatingPromptSystem: Label3D not found in ", prompt_component.name)
