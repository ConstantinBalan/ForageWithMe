@tool
extends EditorPlugin

var dialog

func _enter_tree() -> void:
	# Load the script first
	var dialog_script = load("res://addons/resource_creator/resource_creator_dialog.gd")
	dialog = dialog_script.new()
	dialog.hide()
	get_editor_interface().get_base_control().add_child(dialog)
	
	# Add menu item
	add_tool_menu_item("Create Game Resource", _show_dialog)

func _exit_tree() -> void:
	remove_tool_menu_item("Create Game Resource")
	if dialog:
		dialog.queue_free()

func _show_dialog() -> void:
	dialog.show()
