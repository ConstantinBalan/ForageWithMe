extends Node

# This system could contain logic for how relationships change over time
# or based on more complex events. For now, adjustments are often
# triggered directly by interactions.

signal relationship_changed(entity, villager_name, new_value)

func _ready():
	add_to_group("relationship_system")

func set_relationship(entity: Node, villager_name: String, value: int):
	var relationship_component = entity.get_node_or_null("RelationshipComponent")
	if not relationship_component:
		push_error("RelationshipSystem: Entity does not have a RelationshipComponent")
		return
		
	var clamped_value = clamp(value, 0, 100)
	relationship_component.relationships[villager_name] = clamped_value
	emit_signal("relationship_changed", entity, villager_name, clamped_value)
	print("Set relationship with %s to %d" % [villager_name, clamped_value])

func adjust_relationship(entity: Node, villager_name: String, amount: int):
	var relationship_component = entity.get_node_or_null("RelationshipComponent")
	if not relationship_component:
		push_error("RelationshipSystem: Entity does not have a RelationshipComponent")
		return
		
	var current = get_relationship(entity, villager_name)
	set_relationship(entity, villager_name, current + amount)
	print("Adjusted relationship with %s by %d" % [villager_name, amount])

func get_relationship(entity: Node, villager_name: String) -> int:
	var relationship_component = entity.get_node_or_null("RelationshipComponent")
	if not relationship_component:
		push_error("RelationshipSystem: Entity does not have a RelationshipComponent")
		return 0
		
	return relationship_component.relationships.get(villager_name, 0)
