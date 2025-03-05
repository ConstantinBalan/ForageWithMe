extends Control

@onready var item_container = $ItemContainer # Example: A GridContainer

func _ready():
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		if player.has_node("InventoryComponent"):
			player.get_node("InventoryComponent").inventory_changed.connect(_update_display)
			_update_display()

func _update_display():
	if item_container == null:
		return

	# Clear existing items
	for child in item_container.get_children():
		child.queue_free()

	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		if player.has_node("InventoryComponent"):
			var inventory = player.get_node("InventoryComponent").items
			for item_name in inventory:
				var item_label = Label.new()
				item_label.text = "%s: %d" % [item_name, inventory[item_name]]
				item_container.add_child(item_label)
