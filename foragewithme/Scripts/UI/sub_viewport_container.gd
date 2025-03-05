# Add this to your main scene script (the one with SubViewportContainer)
extends Control

func _ready():
	var viewport = $SubViewportContainer/SubViewport
	
	# These settings are crucial for mouse input to work
	viewport.handle_input_locally = true
	viewport.gui_disable_input = false
	$SubViewportContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make sure the viewport is the right size
	viewport.size = get_viewport().size
