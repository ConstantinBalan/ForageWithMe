extends Node

signal relationship_changed(villager_name, new_value)

var relationships = {} # { "villager1": 75, "villager2": 20 }

func set_relationship(villager_name: String, value: int):
	relationships[villager_name] = clamp(value, 0, 100)
	emit_signal("relationship_changed", villager_name, relationships[villager_name])
	print("Set relationship with %s to %d" % [villager_name, relationships[villager_name]])

func adjust_relationship(villager_name: String, amount: int):
	if relationships.has(villager_name):
		relationships[villager_name] = clamp(relationships[villager_name] + amount, 0, 100)
	else:
		relationships[villager_name] = clamp(amount, 0, 100)
	emit_signal("relationship_changed", villager_name, relationships[villager_name])
	print("Adjusted relationship with %s by %d. New value: %d" % [villager_name, amount, relationships[villager_name]])

func get_relationship(villager_name: String) -> int:
	return relationships.get(villager_name, 0)
