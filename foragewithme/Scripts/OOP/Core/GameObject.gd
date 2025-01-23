extends StaticBody3D
class_name GameObject

# Base class for all game objects
var object_id: String
var interaction_range: float = 2.0

func _init():
	object_id = str(get_instance_id())

func _ready():
	add_to_group("game_objects")

func can_interact_with(other: Node3D) -> bool:
	if not is_instance_valid(other):
		return false
	return global_position.distance_to(other.global_position) <= interaction_range

func interact_with(_interactor: Node3D) -> void:
	pass # Override in child classes
