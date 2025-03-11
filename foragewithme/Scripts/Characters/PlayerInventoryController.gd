extends Node

signal inventory_toggled(is_open: bool) # Used by camera_holder.gd to manage camera state

@onready var inventory_panel = get_tree().get_first_node_in_group("inventory_ui")
@onready var player = get_tree().get_first_node_in_group("player")

var is_inventory_open = false
var inventory: Dictionary = {} # Simple dictionary for item counts
var inventory_data = [] # Detailed inventory data for UI
var inventory_size: int = 24 # Default size
var item_textures: Dictionary = {} # Store item textures

func _ready():
	add_to_group("inventory_controller")
	
	if !inventory_panel:
		push_error("PlayerInventoryController: No inventory panel found!")
		return
	if !player:
		push_error("PlayerInventoryController: No player found!")
		return
		
	# Connect to inventory panel signals
	if inventory_panel.has_signal("item_moved"):
		inventory_panel.item_moved.connect(_on_inventory_item_moved)
	
	# Initialize empty inventory slots
	inventory_data.resize(inventory_size)
	for i in range(inventory_size):
		inventory_data[i] = {}

func _input(event):
	if event.is_action_pressed("Inventory"):
		if is_inventory_open:
			close_inventory()
		else:
			open_inventory()
			print("Current inventory:", inventory) # Print current inventory
	elif event.is_action_pressed("ui_cancel") and is_inventory_open:
		close_inventory()

func open_inventory():
	if !inventory_panel or !player:
		return
		
	is_inventory_open = true
	inventory_panel.visible = true
	
	# Show mouse cursor and make it able to interact with UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Disable player movement and camera rotation
	player.set_process_input(false)
	player.set_physics_process(false)
	
	emit_signal("inventory_toggled", true)

func close_inventory():
	if !inventory_panel or !player:
		return
		
	is_inventory_open = false
	inventory_panel.visible = false
	
	# Hide mouse cursor and lock it for game input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Enable player movement and camera rotation
	player.set_process_input(true)
	player.set_physics_process(true)
	
	emit_signal("inventory_toggled", false)

func _on_inventory_item_moved(from_index: int, to_index: int) -> void:
	var from_item = inventory_data[from_index]
	var to_item = inventory_data[to_index]
	
	# If both slots have items and they are the same type
	if !from_item.is_empty() and !to_item.is_empty() and from_item.name == to_item.name:
		# Add quantities
		to_item.quantity += from_item.quantity
		# Clear the source slot
		inventory_data[from_index] = {}
	else:
		# Regular swap
		var temp = inventory_data[from_index]
		inventory_data[from_index] = inventory_data[to_index]
		inventory_data[to_index] = temp
	
	# Update both slots in the UI
	if inventory_panel:
		inventory_panel.update_slot(from_index, inventory_data[from_index])
		inventory_panel.update_slot(to_index, inventory_data[to_index])

func add_item(item_name: String, item_texture: Texture2D = null) -> bool:
	print("Adding item to inventory:", item_name) # Debug print
	
	# Store texture if provided
	if item_texture:
		item_textures[item_name] = item_texture
	
	# Update simple inventory count
	if item_name in inventory:
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	
	# Try to add to UI inventory
	if inventory_panel:
		# Find first empty slot or stack with same item
		for i in range(inventory_size):
			if inventory_data[i] == {}:
				# Empty slot - add new item
				var item_data = {
					"name": item_name,
					"quantity": 1,
					"texture": item_textures.get(item_name)
				}
				inventory_data[i] = item_data
				inventory_panel.update_slot(i, item_data)
				return true
			elif inventory_data[i] and inventory_data[i].name == item_name:
				# Stack with existing item
				inventory_data[i].quantity += 1
				inventory_panel.update_slot(i, inventory_data[i])
				return true
	
	return true # Always return true for simple inventory

func get_inventory() -> Dictionary:
	return inventory

func has_item(item_name: String) -> bool:
	return item_name in inventory and inventory[item_name] > 0

func remove_item(item_name: String) -> bool:
	if not has_item(item_name):
		return false
	
	# Update simple inventory
	inventory[item_name] -= 1
	if inventory[item_name] <= 0:
		inventory.erase(item_name)
		item_textures.erase(item_name) # Clean up texture
	
	# Update UI inventory
	if inventory_panel:
		for i in range(inventory_size):
			if inventory_data[i] and inventory_data[i].name == item_name:
				inventory_data[i].quantity -= 1
				if inventory_data[i].quantity <= 0:
					inventory_data[i] = {}
				inventory_panel.update_slot(i, inventory_data[i])
				break
	
	return true
