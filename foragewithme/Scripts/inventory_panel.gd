extends Panel

signal item_moved(from_index: int, to_index: int)
signal inventory_toggled(is_open: bool)

@onready var grid_container = $GridContainer
@onready var inventory_system = get_tree().get_first_node_in_group("inventory_system")

var inventory_slots = []
var dragged_item = null
var original_slot = null
var is_open = false

func _ready():
	print("InventoryPanel: Initializing...")
	
	if !grid_container:
		push_error("InventoryPanel: No GridContainer found!")
		return
		
	# Hide the panel initially
	visible = false
	is_open = false
	
	# Set up grid container properties
	grid_container.custom_minimum_size = Vector2(400, 300)  # Adjust overall size
	grid_container.add_theme_constant_override("h_separation", 8)  # Add some spacing
	grid_container.add_theme_constant_override("v_separation", 8)
	
	# Make sure we can receive input
	mouse_filter = Control.MOUSE_FILTER_STOP
	grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Initialize inventory slots
	for slot in grid_container.get_children():
		if !slot.has_node("ItemDisplay"):
			push_error("InventoryPanel: Slot is missing ItemDisplay node!")
			continue
		if !slot.has_node("CountLabel"):
			push_error("InventoryPanel: Slot is missing CountLabel node!")
			continue
			
		inventory_slots.append(slot)
		slot.gui_input.connect(_on_slot_gui_input.bind(slot))
		
	if inventory_system:
		inventory_system.inventory_changed.connect(_on_inventory_changed)
		print("InventoryPanel: Connected to inventory system")
	else:
		push_error("InventoryPanel: No inventory system found!")
		
	# Connect to player input system
	var input_system = get_tree().get_first_node_in_group("player_input_system")
	if input_system:
		input_system.inventory_toggled.connect(toggle_inventory)
		print("InventoryPanel: Connected to player input system")
	else:
		push_error("InventoryPanel: No player input system found!")

func _on_slot_gui_input(event: InputEvent, slot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(slot)
			else:
				_end_drag(slot)

func _start_drag(slot):
	if !slot.item_data or slot.item_data.size() == 0:
		return
		
	dragged_item = slot.item_data
	original_slot = slot
	
	# Create and setup drag preview
	var preview = slot.get_drag_preview()
	if preview:
		get_viewport().set_drag_preview(preview)
		
	print("Started dragging item from slot")

func _end_drag(target_slot):
	if !dragged_item or !original_slot:
		return
		
	if target_slot != original_slot:
		var from_index = inventory_slots.find(original_slot)
		var to_index = inventory_slots.find(target_slot)
		
		if from_index >= 0 and to_index >= 0:
			# Swap items between slots
			var target_item = target_slot.item_data.duplicate()
			target_slot.item_data = dragged_item.duplicate()
			original_slot.item_data = target_item
			
			emit_signal("item_moved", from_index, to_index)
			print("Moved item from slot ", from_index, " to slot ", to_index)
	
	dragged_item = null
	original_slot = null

func _on_inventory_changed(inventory_data):
	print("InventoryPanel: Inventory changed")
	for i in range(min(inventory_slots.size(), inventory_data.size())):
		inventory_slots[i].item_data = inventory_data[i]

func toggle_inventory():
	is_open = !is_open
	visible = is_open
	emit_signal("inventory_toggled", is_open)
