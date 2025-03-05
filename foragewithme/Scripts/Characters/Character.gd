extends CharacterBody3D
class_name Character

signal inventory_changed
signal relationship_changed

# Base GameObject properties
var object_id: String
var interaction_range: float = 2.0

# Movement properties
var speed: float = 5.0
var sprint_speed: float = 10.0
var jump_velocity: float = 4.5
var current_speed: float = 5.0

var inventory: Dictionary = {}
var relationships: Dictionary = {}

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

# Inventory methods
func add_item(item_id: String, amount: int = 1) -> bool:
	if item_id in inventory:
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	emit_signal("inventory_changed")
	return true

func remove_item(item_id: String, amount: int = 1) -> bool:
	if item_id in inventory and inventory[item_id] >= amount:
		inventory[item_id] -= amount
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		emit_signal("inventory_changed")
		return true
	return false

# Relationship methods
func change_relationship(character_id: String, amount: float) -> void:
	if character_id in relationships:
		relationships[character_id] += amount
	else:
		relationships[character_id] = amount
	emit_signal("relationship_changed", character_id)

func get_relationship(character_id: String) -> float:
	return relationships.get(character_id, 0.0)
