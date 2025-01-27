extends Node

signal inventory_toggled(is_open: bool)

@onready var inventory_panel = get_tree().get_first_node_in_group("inventory_ui")
@onready var player = get_tree().get_first_node_in_group("player")

var is_inventory_open = false
var inventory_data = []  # Will store the actual inventory items

func _ready():
	if !inventory_panel:
		push_error("PlayerInventoryController: No inventory panel found!")
		return
	if !player:
		push_error("PlayerInventoryController: No player found!")
		return
		
	# Connect to inventory panel signals
	inventory_panel.item_moved.connect(_on_inventory_item_moved)
	
	# Initialize empty inventory with 24 slots (example)
	for i in range(24):
		inventory_data.append({})

func _input(event):
	if event.is_action_pressed("Inventory"):
		toggle_inventory()
	elif event.is_action_pressed("ui_cancel") and is_inventory_open:
		close_inventory()

func toggle_inventory():
	if is_inventory_open:
		close_inventory()
	else:
		open_inventory()

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
	# Swap items in the inventory data
	var temp = inventory_data[from_index]
	inventory_data[from_index] = inventory_data[to_index]
	inventory_data[to_index] = temp
	
	# Update the UI to reflect the changes
	if inventory_panel:
		inventory_panel.update_slot(from_index, inventory_data[from_index])
		inventory_panel.update_slot(to_index, inventory_data[to_index])

# Function to add an item to the inventory
func add_item(item_data: Dictionary) -> bool:
	# Find first empty slot
	for i in range(inventory_data.size()):
		if inventory_data[i].is_empty():
			inventory_data[i] = item_data
			if inventory_panel:
				inventory_panel.update_slot(i, item_data)
			return true
	return false  # Inventory is full
