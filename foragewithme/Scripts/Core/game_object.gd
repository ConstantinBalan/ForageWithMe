class_name GameObject
extends StaticBody3D

@export var hover_label_text: String = "" # Text to show when hovered
# Base class for all game objects
var object_id: String
var interaction_range: float = 2.0 # Kept for backward compatibility

func _init():
	object_id = str(get_instance_id())

func _ready():
	add_to_group("game_objects")
	# Make sure collision is enabled for raycast detection
	collision_layer = 2

func can_interact_with(other: Node3D) -> bool:
	if not is_instance_valid(other):
		return false
	# The actual interaction check is now handled by the player's raycast
	# This method is kept for compatibility and can be used for additional checks
	return true

func interact_with(_interactor: Node3D) -> void:
	pass # Override in child classes

func get_hover_text() -> String:
	return hover_label_text if hover_label_text else name

func show_hover_label() -> void:
	var label_manager = get_tree().get_first_node_in_group("game_object_label_manager")
	if label_manager:
		label_manager.show_label(self, get_hover_text())

func hide_hover_label() -> void:
	var label_manager = get_tree().get_first_node_in_group("game_object_label_manager")
	if label_manager:
		label_manager.hide_label(self)
