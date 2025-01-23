extends Panel

var item_data: Dictionary = {}
@onready var item_display = $ItemDisplay
@onready var count_label = $CountLabel

func _ready():
	# Set minimum size for the slot
	custom_minimum_size = Vector2(64, 64)  # Make slots bigger
	
	# Make sure the panel can receive input
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Make sure child controls don't block input
	if item_display:
		item_display.mouse_filter = Control.MOUSE_FILTER_PASS
		item_display.custom_minimum_size = Vector2(48, 48)  # Make icon bigger
		
	if count_label:
		count_label.mouse_filter = Control.MOUSE_FILTER_PASS
	
	print("InventorySlot: Initialized and ready for input")
	print("InventorySlot: Mouse filter = ", mouse_filter)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		print("InventorySlot: Received mouse button: ", event.as_text())
		print("InventorySlot: Item data = ", item_data)
	get_viewport().set_input_as_handled()  # Prevent input from propagating

func get_drag_preview():
	if !item_data or !item_display:
		return null
		
	var preview = TextureRect.new()
	preview.texture = item_display.texture
	preview.custom_minimum_size = Vector2(48, 48)
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.modulate.a = 0.7  # Make it slightly transparent
	return preview
