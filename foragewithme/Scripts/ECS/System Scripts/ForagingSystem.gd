extends Node

signal forage_attempted(entity: Node, success: bool)
signal item_respawned(entity: Node)

var inventory_system = null

func _ready():
	add_to_group("foraging_system")
	print("ForagingSystem: Initializing...")
	call_deferred("_connect_inventory")

func _connect_inventory():
	# Try to find the inventory system
	inventory_system = get_tree().get_first_node_in_group("inventory_system")
	if !inventory_system:
		push_error("ForagingSystem: Failed to find InventorySystem")
	else:
		print("ForagingSystem: Successfully connected to InventorySystem")

func _ensure_inventory_system() -> bool:
	if !inventory_system:
		inventory_system = get_tree().get_first_node_in_group("inventory_system")
	return inventory_system != null

func can_forage(forageable: Node) -> bool:
	if !forageable.forageable_item:
		push_error("ForagingSystem: No ForageableItem resource set on component")
		return false
		
	if forageable.quantity_available <= 0:
		var current_time = Time.get_unix_time_from_system()
		if current_time - forageable.last_foraged_time >= forageable.respawn_time:
			print("ForagingSystem: Item ready to respawn")
			_respawn(forageable)
			return true
		print("ForagingSystem: Item not ready yet. Time remaining: ", 
			ceil(forageable.respawn_time - (current_time - forageable.last_foraged_time)), 
			" seconds")
		return false
	return true

func _respawn(forageable: Node) -> void:
	print("ForagingSystem: Respawning ", forageable.forageable_item.name)
	forageable.quantity_available = 5  # Reset to initial quantity
	if forageable.mesh_instance:
		forageable.mesh_instance.visible = true
	emit_signal("item_respawned", forageable)

# This is the main entry point called by the InteractionSystem
func forage(player: Node, interactable: Node) -> void:
	print("ForagingSystem: Handling forage request from player")
	
	# Get the forageable component
	var forageable = interactable.get_node_or_null("ForageableComponent")
	if not forageable:
		push_error("ForagingSystem: No ForageableComponent found on ", interactable.name)
		return
		
	print("ForagingSystem: Found ForageableComponent with item: ", 
		forageable.forageable_item.name if forageable.forageable_item else "None")
	
	# Try to forage
	if can_forage(forageable):
		print("ForagingSystem: Can forage item")
		forageable.quantity_available -= 1
		print("ForagingSystem: Remaining quantity: ", forageable.quantity_available)
		
		if forageable.quantity_available <= 0:
			print("ForagingSystem: Item depleted, starting respawn timer")
			forageable.last_foraged_time = Time.get_unix_time_from_system()
			if forageable.mesh_instance:
				forageable.mesh_instance.visible = false
		
		# Try to ensure we have the inventory system
		if _ensure_inventory_system():
			print("ForagingSystem: Attempting to add item to inventory")
			print("ForagingSystem: Item texture is ", "SET" if forageable.forageable_item.texture else "NULL")
			print("ForagingSystem: Item name is ", forageable.forageable_item.name)
			inventory_system.add_item(forageable.forageable_item)
			emit_signal("forage_attempted", interactable, true)
			print("ForagingSystem: Called add_item on inventory_system")
		else:
			push_error("ForagingSystem: Could not find InventorySystem!")
	else:
		emit_signal("forage_attempted", interactable, false)
