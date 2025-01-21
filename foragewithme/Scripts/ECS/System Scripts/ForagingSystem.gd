extends Node

# The core foraging logic is now largely within the InteractionSystem
# This system could handle more complex foraging mechanics in the future

signal forage_attempted(entity: Node, success: bool, amount: int)
signal item_respawned(entity: Node)

func _ready():
	add_to_group("foraging_system")

func can_forage(forageable_component: Node) -> bool:
	if forageable_component.quantity_available <= 0:
		print("No more ", forageable_component.item_type, " available")
		return false
	
	var current_time = Time.get_unix_time_from_system()
	if current_time - forageable_component.last_foraged_time < forageable_component.respawn_time:
		print(forageable_component.item_type, " not ready yet. ", 
			ceil(forageable_component.respawn_time - (current_time - forageable_component.last_foraged_time)), 
			" seconds remaining")
		return false
		
	return true

func attempt_forage(forageable_component: Node, amount: int = 1) -> Dictionary:
	if can_forage(forageable_component):
		var actual_amount = min(amount, forageable_component.quantity_available)
		forageable_component.quantity_available -= actual_amount
		forageable_component.last_foraged_time = Time.get_unix_time_from_system()
		print("Foraged ", actual_amount, " ", forageable_component.item_type, 
			". ", forageable_component.quantity_available, " remaining")
		emit_signal("forage_attempted", forageable_component, true, actual_amount)
		return {"item_type": forageable_component.item_type, "quantity": actual_amount}
	
	emit_signal("forage_attempted", forageable_component, false, 0)
	return {}

# This is the main entry point called by the InteractionSystem
func forage(player: Node, interactable: Node) -> void:
	print("ForagingSystem handling forage request from player")
	
	# Get the forageable component
	var forageable = interactable.get_node_or_null("ForageableComponent")
	if not forageable:
		push_error("ForagingSystem: No ForageableComponent found on ", interactable.name)
		return
		
	# Try to forage
	var result = attempt_forage(forageable)
	if not result.is_empty():
		# Get the player's inventory
		var inventory = player.get_node_or_null("InventoryComponent")
		if inventory:
			var inventory_system = get_tree().get_first_node_in_group("inventory_system")
			if inventory_system:
				inventory_system.add_item(inventory, result.item_type, result.quantity)
			else:
				push_error("ForagingSystem: InventorySystem not found")
		else:
			push_error("ForagingSystem: Player has no InventoryComponent")
