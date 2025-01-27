extends Panel

var item_data = {}
var default_style: StyleBoxFlat
var hover_style: StyleBoxFlat
var is_hovered = false

func _ready():
	# Set minimum size for the slot
	custom_minimum_size = Vector2(64, 64)
	
	# Create styles
	default_style = StyleBoxFlat.new()
	default_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	default_style.border_width_left = 2
	default_style.border_width_top = 2
	default_style.border_width_right = 2
	default_style.border_width_bottom = 2
	default_style.border_color = Color(0.1, 0.1, 0.1, 1)
	
	hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	hover_style.border_width_left = 2
	hover_style.border_width_top = 2
	hover_style.border_width_right = 2
	hover_style.border_width_bottom = 2
	hover_style.border_color = Color(1, 1, 1, 1)
	
	# Set initial style
	add_theme_stylebox_override("panel", default_style)
	
	# Enable mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	is_hovered = true
	add_theme_stylebox_override("panel", hover_style)
	print("Mouse entered slot")

func _on_mouse_exited() -> void:
	is_hovered = false
	add_theme_stylebox_override("panel", default_style)
	print("Mouse exited slot")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !is_hovered:
		_on_mouse_entered()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("Clicked slot")
	
	# Prevent input from propagating
	get_viewport().set_input_as_handled()
