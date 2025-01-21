extends Node

# These signals can be used by other systems for effects (sound, particles, etc.)
signal interaction_possible(interactable) # Emitted when entering interaction range
signal interaction_ended(interactable) # Emitted when leaving interaction range
signal interaction_occurred(interactor, interactable) # Emitted when actually interacting

const INTERACTION_DISTANCE = 3.0
const HEAD_HEIGHT = 1.5 # Adjust this based on your character's height

var current_interactable = null
var debug_draw = false # Set to false to disable debug lines

# Cached node references
var player_entity: Node
var character_body: CharacterBody3D
var camera: Camera3D
var raycast: RayCast3D
var floating_prompt_system: Node

func _ready():
	add_to_group("interaction_system")
	await get_tree().process_frame
	setup_input_system()
	
	floating_prompt_system = get_tree().get_first_node_in_group("floating_prompt_system")
	if not floating_prompt_system:
		push_error("InteractionSystem: FloatingPromptSystem not found!")
	
	setup_player_references()

func setup_input_system():
	var input_system = get_tree().get_first_node_in_group("player_input_system")
	if input_system:
		if input_system.interaction_requested.is_connected(_on_interaction_requested):
			input_system.interaction_requested.disconnect(_on_interaction_requested)
		input_system.interaction_requested.connect(_on_interaction_requested)
	else:
		push_error("PlayerInputSystem not found!")
		await get_tree().process_frame
		setup_input_system()

func setup_player_references():
	if get_tree().has_group("player"):
		player_entity = get_tree().get_nodes_in_group("player")[0]
		character_body = player_entity.owner # Get the CharacterBody3D
		camera = character_body.get_node("CameraHolder/Camera3D")
		raycast = character_body.get_node("CameraHolder/Camera3D/RayCast3D")
		
		if not camera or not raycast:
			push_error("InteractionSystem: Camera or Raycast not found!")

func find_interactable_node(node: Node) -> Node:
	var interactable = node
	if node.has_node("InteractableComponent"):
		interactable = node
	elif node is CharacterBody3D:
		for child in node.get_children():
			if child.has_node("InteractableComponent"):
				interactable = child
				break
	if not interactable.has_node("InteractableComponent"):
		var parent = node.get_parent()
		if parent and parent.has_node("InteractableComponent"):
			interactable = parent
	return interactable if interactable.has_node("InteractableComponent") else null

func _physics_process(_delta):
	if not player_entity or not camera or not raycast:
		return
		
	var head_position = character_body.global_position + Vector3(0, HEAD_HEIGHT, 0)
	raycast.global_position = head_position
	raycast.global_rotation = camera.global_rotation
	raycast.target_position = Vector3(0, 0, -INTERACTION_DISTANCE)
	raycast.collision_mask = 2 # Layer for interactable objects
	
	if debug_draw:
		var end_point = raycast.global_position + raycast.global_transform.basis.z * -INTERACTION_DISTANCE
		var debug_color = Color.GREEN if raycast.is_colliding() else Color.RED
		$DebugDraw.draw_line(raycast.global_position, end_point, debug_color)
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var interactable = find_interactable_node(collider)
		if interactable:
			highlight_interactable(interactable)
		else:
			clear_highlight()
	else:
		clear_highlight()

func highlight_interactable(interactable):
	if interactable != current_interactable:
		if current_interactable:
			interaction_ended.emit(current_interactable)
			update_prompt_visibility(current_interactable, false)
			
		current_interactable = interactable
		
		interaction_possible.emit(current_interactable)
		update_prompt_text(current_interactable)
	elif current_interactable:
		update_prompt_text(current_interactable)

func clear_highlight():
	if current_interactable:
		interaction_ended.emit(current_interactable)
		update_prompt_visibility(current_interactable, false)
		current_interactable = null

func _on_interaction_requested(player):
	if not current_interactable:
		return
		
	interaction_occurred.emit(player, current_interactable)
	
	var forageable = current_interactable.get_node_or_null("ForageableComponent")
	if forageable:
		var foraging_system = get_tree().get_first_node_in_group("foraging_system")
		if foraging_system:
			foraging_system.forage(player, current_interactable)
		else:
			push_error("ForagingSystem not found")
	
	var villager = current_interactable.get_node_or_null("VillagerComponent")
	if villager:
		var villager_system = get_tree().get_first_node_in_group("villager_system")
		if villager_system:
			villager_system.interact(player, current_interactable)
		else:
			push_error("VillagerSystem not found")

func update_prompt_visibility(interactable, visible: bool):
	var component = interactable.get_node_or_null("InteractableComponent")
	if not component:
		push_error("InteractableComponent not found on ", interactable.name)
		return
		
	if not floating_prompt_system:
		push_error("FloatingPromptSystem not found")
		return
		
	if not component.floating_prompt:
		push_error("FloatingPromptComponent not found in InteractableComponent")
		return
		
	if visible:
		var text = get_prompt_text(interactable)
		floating_prompt_system.show_prompt(component.floating_prompt, text)
	else:
		floating_prompt_system.hide_prompt(component.floating_prompt)

func update_prompt_text(interactable):
	update_prompt_visibility(interactable, true)

func get_prompt_text(interactable) -> String:
	var text = "Press E to interact"
	
	if interactable.has_node("ForageableComponent"):
		text = "Press E to forage"
	elif interactable.get_parent().is_in_group("villager"):
		text = "Press E to talk"
		
	return text
