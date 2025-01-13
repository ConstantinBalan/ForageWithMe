extends Node

signal inventory_changed

var items = {}  # { "wood": 10, "berries": 5 }

func add_item(item_name: String, quantity: int = 1):
	if items.has(item_name):
		items[item_name] += quantity
	else:
		items[item_name] = quantity
	emit_signal("inventory_changed")
	print("Added %d %s. New quantity: %d" % [quantity, item_name, items[item_name]])

func remove_item(item_name: String, quantity: int = 1):
	if items.has(item_name):
		if items[item_name] >= quantity:
			items[item_name] -= quantity
			if items[item_name] == 0:
				items.erase(item_name)
			emit_signal("inventory_changed")
			print("Removed %d %s. New quantity: %s" % [quantity, item_name, items.get(item_name, 0)])
		else:
			print("Not enough %s to remove." % item_name)
	else:
		print("%s not found in inventory." % item_name)

func has_item(item_name: String, quantity: int = 1) -> bool:
	return items.has(item_name) and items[item_name] >= quantity

func get_item_quantity(item_name: String) -> int:
	return items.get(item_name, 0)
