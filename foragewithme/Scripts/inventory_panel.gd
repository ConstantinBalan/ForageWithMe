extends Control

signal item_moved(from_index: int, to_index: int)

@onready var grid_container = $Panel/GridContainer
@onready var panel = $Panel

var inventory_slots = []
var dragged_slot = null
var drag_preview = null
var drag_offset = Vector2()
var is_open = false
var hovered_slot = null

func _ready():
	print("InventoryPanel: Initializing...")
	
	# Initial setup
	visible = false
	is_open = false
	
	# Configure the main Control node (self)
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Configure the Panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Configure GridContainer
	grid_container.columns = 6
	grid_container.add_theme_constant_override("h_separation", 8)
	grid_container.add_theme_constant_override("v_separation", 8)
	
	# Make sure Panel can receive input but GridContainer passes it through
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Initialize inventory slots
	for slot in grid_container.get_children():
		inventory_slots.append(slot)
		slot.gui_input.connect(_on_slot_gui_input.bind(slot))
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		if slot.has_node("ItemDisplay"):
			slot.get_node("ItemDisplay").mouse_filter = Control.MOUSE_FILTER_PASS
		if slot.has_node("CountLabel"):
			slot.get_node("CountLabel").mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Calculate sizes
	var slot_size = Vector2(64, 64)
	var spacing = Vector2(8, 8)
	var columns = grid_container.columns
	var rows = ceil(float(inventory_slots.size()) / columns)
	
	# Calculate grid size
	var grid_width = (slot_size.x * columns) + (spacing.x * (columns - 1))
	var grid_height = (slot_size.y * rows) + (spacing.y * (rows - 1))
	
	# Set minimum sizes with padding
	var padding = Vector2(32, 32)
	grid_container.custom_minimum_size = Vector2(grid_width, grid_height)
	panel.custom_minimum_size = Vector2(
		grid_width + padding.x * 2,
		grid_height + padding.y * 2
	)
	
	# Position panel in top left with margin
	var margin = Vector2(20, 20) # Margin from screen edges
	panel.anchor_left = 0
	panel.anchor_top = 0
	panel.anchor_right = 0
	panel.anchor_bottom = 0
	panel.position = margin
	
	# Position grid inside panel with padding
	grid_container.position = padding

func _process(_delta):
	if drag_preview and dragged_slot:
		drag_preview.global_position = get_viewport().get_mouse_position() - drag_offset
		
		# Find slot under mouse
		var mouse_pos = get_viewport().get_mouse_position()
		var found_slot = null
		for slot in inventory_slots:
			if slot != dragged_slot:
				var slot_rect = Rect2(slot.global_position, slot.size)
				if slot_rect.has_point(mouse_pos):
					found_slot = slot
					break
		
		# Update hover states
		if found_slot != hovered_slot:
			if hovered_slot:
				hovered_slot.add_theme_stylebox_override("panel", hovered_slot.default_style)
			if found_slot:
				found_slot.add_theme_stylebox_override("panel", found_slot.hover_style)
			hovered_slot = found_slot

func _gui_input(_event: InputEvent) -> void:
	if is_open:
		get_viewport().set_input_as_handled()

func create_drag_preview(slot):
	# Create a new TextureRect for the preview
	drag_preview = TextureRect.new()
	drag_preview.texture = slot.get_node("ItemDisplay").texture
	drag_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	drag_preview.custom_minimum_size = slot.custom_minimum_size
	drag_preview.size = slot.size
	drag_preview.modulate.a = 0.7
	add_child(drag_preview)
	
	# Calculate offset so the item centers on the mouse
	drag_offset = drag_preview.size / 2

func remove_drag_preview():
	if drag_preview:
		drag_preview.queue_free()
		drag_preview = null

func _on_slot_gui_input(event: InputEvent, slot):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if !slot.item_data.is_empty():
				dragged_slot = slot
				create_drag_preview(slot)
				slot.start_drag()
		else:
			if dragged_slot:
				var from_index = inventory_slots.find(dragged_slot)
				var to_slot = hovered_slot if hovered_slot else slot
				var to_index = inventory_slots.find(to_slot)
				
				if from_index != -1 and to_index != -1 and from_index != to_index:
					emit_signal("item_moved", from_index, to_index)
				
				if hovered_slot:
					hovered_slot.add_theme_stylebox_override("panel", hovered_slot.default_style)
					hovered_slot = null
				
				dragged_slot.end_drag()
				dragged_slot = null
				remove_drag_preview()
	
	get_viewport().set_input_as_handled()

func update_slot(slot_index: int, item_data: Dictionary) -> void:
	if slot_index < 0 or slot_index >= inventory_slots.size():
		return
		
	var slot = inventory_slots[slot_index]
	slot.item_data = item_data
	
	if slot.has_node("ItemDisplay"):
		var texture_rect = slot.get_node("ItemDisplay")
		texture_rect.texture = item_data.get("texture", null)
	
	if slot.has_node("CountLabel"):
		var count_label = slot.get_node("CountLabel")
		var count = item_data.get("count", 0)
		count_label.text = str(count) if count > 1 else ""

func toggle_inventory():
	is_open = !is_open
	visible = is_open
