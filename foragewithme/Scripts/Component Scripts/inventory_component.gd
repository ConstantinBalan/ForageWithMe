extends Node

signal inventory_changed(items)
signal item_added(item)
signal item_removed(item)

var items = []
var capacity = 20

func add_item(item):
	if items.size() < capacity:
		items.append(item)
		item_added.emit(item)
		inventory_changed.emit(items)
		return true
	return false
	
func remove_item(item):
	items.erase(item)
	item_removed.emit(item)
	inventory_changed.emit(items)
	return true
