extends Node

# These signals can be used by other systems for effects (sound, particles, etc.)
signal interaction_possible(interactable) # Emitted when entering interaction range
signal interaction_ended(interactable) # Emitted when leaving interaction range
signal interaction_occurred(interactable) # Emitted when actually interacting

@export var interaction_distance = 3.0
@export var interaction_cooldown = 0.5 # Half second cooldown between interactions
var current_interactable = null
var last_interaction_time = 0.0

func _ready():
	print("InteractionSystem initialized")
	add_to_group("interaction_system")

func _physics_process(_delta):
	if not get_tree().has_group("player"):
		return
		
	var player = get_tree().get_nodes_in_group("player")[0]
	var character_body = player.owner # Get the CharacterBody3D
	if not character_body:
		return
		
	var nearest = find_nearest_interactable(character_body)
	if nearest != current_interactable:
		# End current interaction if there was one
		if current_interactable:
			interaction_ended.emit(current_interactable)
			update_prompt_visibility(current_interactable, false)
			
		current_interactable = nearest
		
		# Start new interaction if we found one
		if current_interactable:
			interaction_possible.emit(current_interactable)
			update_prompt_text(current_interactable)
	elif current_interactable:
		# Update prompt text every frame for current interactable
		update_prompt_text(current_interactable)
	
	if Input.is_action_just_pressed("Interact") and current_interactable:
		var current_time = Time.get_unix_time_from_system()
		if current_time - last_interaction_time >= interaction_cooldown:
			interact_with_object(player, current_interactable)
			last_interaction_time = current_time

func find_nearest_interactable(character_body):
	var closest_distance = interaction_distance
	var closest_interactable = null
	
	for node in get_tree().get_nodes_in_group("interactable"):
		if not (node is Node3D) or node.is_ancestor_of(character_body):
			continue
			
		var distance = character_body.global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_interactable = node
	
	return closest_interactable

func update_prompt_visibility(interactable: Node, visible: bool):
	if not interactable:
		return
		
	var interactable_component = interactable.get_node("InteractableComponent")
	if interactable_component:
		if visible:
			update_prompt_text(interactable)
		else:
			interactable_component.hide_interaction_prompt()

func update_prompt_text(interactable: Node):
	var interactable_component = interactable.get_node("InteractableComponent")
	if not interactable_component:
		return
		
	if interactable.has_node("ForageableComponent"):
		var forageable = interactable.get_node("ForageableComponent")
		if forageable.can_forage():
			interactable_component.show_interaction_prompt("Press E to forage " + forageable.item_type)
		else:
			interactable_component.hide_interaction_prompt()
	elif interactable.is_in_group("villager"):
		interactable_component.show_interaction_prompt("Press E to talk")

func interact_with_object(player, interactable):
	print("Attempting to interact with: ", interactable.name)
	if interactable.has_node("ForageableComponent"):
		var forageable = interactable.get_node("ForageableComponent")
		if forageable.can_forage():
			var foraged_items = forageable.forage()
			if not foraged_items.is_empty():
				var inventory = player.get_node("InventoryComponent")
				if inventory:
					inventory.add_item(foraged_items["item_type"], foraged_items["quantity"])
					interaction_occurred.emit(interactable) # Emit when interaction succeeds
			else:
				print(str(interactable.name, " is out of ", forageable.item_type, " to forage"))
	
	# Handle villager interactions
	elif interactable.is_in_group("villager"):
		if interactable.has_script():
			interactable.get_script().interact(player)
			interaction_occurred.emit(interactable) # Emit when interaction succeeds
