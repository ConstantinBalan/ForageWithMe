extends Node

signal inventory_changed(inventory_data: Dictionary)

var inventory: Dictionary = {} # Dictionary of ForageableItem: count
const MAX_SLOTS = 12

func _ready():
	add_to_group("inventory_system")
	print("InventorySystem: Initialized with ", MAX_SLOTS, " slots")

func add_item(item: ForageableItem, count: int = 1):
	print("InventorySystem: add_item called with item: ", item.name if item else "NULL")
	
	if item == null:
		push_error("InventorySystem: Attempted to add null item")
		return
		
	print("InventorySystem: Adding ", count, "x ", item.name)
	print("InventorySystem: Item texture is ", "SET" if item.texture else "NULL")
	
	if inventory.has(item):
		inventory[item] += count
		print("InventorySystem: Increased stack of ", item.name, " to ", inventory[item])
	else:
		if inventory.size() >= MAX_SLOTS:
			push_error("InventorySystem: Inventory full, cannot add ", item.name)
			return
		inventory[item] = count
		print("InventorySystem: Added new item ", item.name, " with count ", count)
	
	var inventory_data = _get_inventory_data()
	print("InventorySystem: Current inventory contents:")
	for slot in inventory_data:
		var slot_data = inventory_data[slot]
		print("- Slot ", slot, ": ", slot_data.item.name, " x", slot_data.count)
	
	print("InventorySystem: Emitting inventory_changed signal")
	emit_signal("inventory_changed", inventory_data)
	print("InventorySystem: Signal emitted")

func remove_item(item: ForageableItem, count: int = 1):
	if item == null:
		push_error("InventorySystem: Attempted to remove null item")
		return
		
	if !inventory.has(item):
		push_error("InventorySystem: Attempted to remove non-existent item ", item.name)
		return
		
	print("InventorySystem: Removing ", count, "x ", item.name)
	inventory[item] -= count
	
	if inventory[item] <= 0:
		inventory.erase(item)
		print("InventorySystem: Removed all of ", item.name)
	else:
		print("InventorySystem: Reduced stack of ", item.name, " to ", inventory[item])
	
	emit_signal("inventory_changed", _get_inventory_data())

func _get_inventory_data() -> Dictionary:
	var data = {}
	var index = 0
	
	for item in inventory:
		if index >= MAX_SLOTS:
			push_warning("InventorySystem: Some items couldn't fit in the inventory UI")
			break
			
		data[index] = {
			"texture": item.texture,
			"count": inventory[item],
			"item": item
		}
		index += 1
	
	return data

func move_item(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= inventory.size() or to_index < 0 or to_index >= MAX_SLOTS:
		push_error("InventorySystem: Invalid slot indices for move operation")
		return
		
	print("InventorySystem: Moving item from slot ", from_index, " to slot ", to_index)
	var data = _get_inventory_data()
	if !data.has(from_index):
		push_error("InventorySystem: No item at source index ", from_index)
		return
		
	# For now, just notify that the move was requested
	# You can implement actual slot swapping later if needed
	print("InventorySystem: Move operation completed")
