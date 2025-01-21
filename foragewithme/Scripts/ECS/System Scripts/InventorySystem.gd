extends Node

signal inventory_changed(entity: Node)

func _ready():
	add_to_group("inventory_system")

func add_item(inventory_component: Node, item_name: String, quantity: int = 1):
	if inventory_component.items.has(item_name):
		inventory_component.items[item_name] += quantity
	else:
		inventory_component.items[item_name] = quantity
	emit_signal("inventory_changed", inventory_component)
	print("Added %d %s. New quantity: %d" % [quantity, item_name, inventory_component.items[item_name]])

func remove_item(inventory_component: Node, item_name: String, quantity: int = 1):
	if inventory_component.items.has(item_name):
		if inventory_component.items[item_name] >= quantity:
			inventory_component.items[item_name] -= quantity
			if inventory_component.items[item_name] == 0:
				inventory_component.items.erase(item_name)
			emit_signal("inventory_changed", inventory_component)
			print("Removed %d %s. New quantity: %s" % [quantity, item_name, inventory_component.items.get(item_name, 0)])
		else:
			print("Not enough %s to remove." % item_name)
	else:
		print("%s not found in inventory." % item_name)

func has_item(inventory_component: Node, item_name: String, quantity: int = 1) -> bool:
	return inventory_component.items.has(item_name) and inventory_component.items[item_name] >= quantity

func get_item_quantity(inventory_component: Node, item_name: String) -> int:
	return inventory_component.items.get(item_name, 0)
