extends Node

@export var interaction_distance = 2.0

func _physics_process(delta):
	if Input.is_action_just_pressed("Interact"):
		interact_with_nearby()

func interact_with_nearby():
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		var player_position = player.global_position

		# Interact with forageables
		for node in get_tree().get_nodes_in_group("forageable"):
			if node.is_ancestor_of(player): continue # Skip if player is the forageable
			if node.global_position.distance_to(player_position) <= interaction_distance:
				attempt_forage(player, node)
				return # Only interact with one thing at a time

		# Interact with villagers
		for node in get_tree().get_nodes_in_group("villager"):
			if node.global_position.distance_to(player_position) <= interaction_distance:
				interact_with_villager(player, node)
				return

func attempt_forage(player, forageable_node):
	if forageable_node.has_node("ForageableComponent"):
		var forageable = forageable_node.get_node("ForageableComponent")
		if forageable.can_forage():
			var foraged_item = forageable.forage()
			if !foraged_item.is_empty():
				player.get_node("InventoryComponent").add_item(foraged_item.item_type, foraged_item.quantity)

func interact_with_villager(player, villager_node):
	if villager_node.has_script():
		villager_node.get_script().interact(player)
