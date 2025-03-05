extends Panel

var item_data = {}
var default_style: StyleBoxFlat
var hover_style: StyleBoxFlat
var drag_style: StyleBoxFlat
var is_hovered = false
var is_dragging = false
var tooltip_label: Label

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
	
	drag_style = StyleBoxFlat.new()
	drag_style.bg_color = Color(0.4, 0.4, 0.4, 0.8)
	drag_style.border_width_left = 2
	drag_style.border_width_top = 2
	drag_style.border_width_right = 2
	drag_style.border_width_bottom = 2
	drag_style.border_color = Color(1, 0.8, 0, 1)
	
	# Set initial style
	add_theme_stylebox_override("panel", default_style)
	
	# Enable mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Create tooltip label
	tooltip_label = Label.new()
	tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tooltip_label.visible = false
	
	# Style the tooltip
	var tooltip_style = StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	tooltip_style.border_width_left = 1
	tooltip_style.border_width_top = 1
	tooltip_style.border_width_right = 1
	tooltip_style.border_width_bottom = 1
	tooltip_style.border_color = Color(1, 1, 1, 0.5)
	tooltip_style.corner_radius_top_left = 4
	tooltip_style.corner_radius_top_right = 4
	tooltip_style.corner_radius_bottom_left = 4
	tooltip_style.corner_radius_bottom_right = 4
	tooltip_style.content_margin_left = 8
	tooltip_style.content_margin_right = 8
	tooltip_style.content_margin_top = 4
	tooltip_style.content_margin_bottom = 4
	
	tooltip_label.add_theme_stylebox_override("normal", tooltip_style)
	add_child(tooltip_label)

func start_drag():
	is_dragging = true
	add_theme_stylebox_override("panel", drag_style)
	if has_node("ItemDisplay"):
		get_node("ItemDisplay").modulate.a = 0.5
	tooltip_label.visible = false

func end_drag():
	is_dragging = false
	add_theme_stylebox_override("panel", default_style)
	if has_node("ItemDisplay"):
		get_node("ItemDisplay").modulate.a = 1.0

func _on_mouse_entered() -> void:
	is_hovered = true
	if !is_dragging:
		add_theme_stylebox_override("panel", hover_style)
		if item_data and "name" in item_data:
			tooltip_label.text = item_data.name
			tooltip_label.visible = true
			# Position tooltip above the slot
			tooltip_label.position = Vector2(
				size.x/2 - tooltip_label.size.x/2,
				-tooltip_label.size.y - 5
			)

func _on_mouse_exited() -> void:
	is_hovered = false
	if !is_dragging:
		add_theme_stylebox_override("panel", default_style)
	tooltip_label.visible = false

func _gui_input(_event: InputEvent) -> void:
	pass

func update_item(new_item_data: Dictionary) -> void:
	item_data = new_item_data
	queue_redraw()
	
	# Hide tooltip if item is removed
	if item_data.is_empty():
		tooltip_label.visible = false

func _draw() -> void:
	if item_data.is_empty():
		return
		
	if "texture" in item_data and item_data.texture:
		var texture = item_data.texture
		var scale = min(size.x / texture.get_width(), size.y / texture.get_height())
		var draw_size = Vector2(texture.get_width() * scale, texture.get_height() * scale)
		var position = Vector2(
			(size.x - draw_size.x) / 2,
			(size.y - draw_size.y) / 2
		)
		draw_texture_rect(texture, Rect2(position, draw_size), false)
		
	if "quantity" in item_data and item_data.quantity > 1:
		var font = ThemeDB.fallback_font
		var font_size = 16
		var text = str(item_data.quantity)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
		var position = Vector2(
			size.x - text_size.x - 5,
			size.y - 5
		)
		draw_string(font, position, text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, Color.WHITE)
