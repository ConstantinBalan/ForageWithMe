extends Node

signal dialogue_started(villager: Node)
signal dialogue_ended(villager: Node)

func _ready():
	add_to_group("villager_system")

func interact(player: Node, interactable: Node) -> void:
	print("VillagerSystem handling interaction request from player")
	
	# Get the villager component
	var villager = interactable.get_node_or_null("VillagerComponent")
	if not villager:
		push_error("VillagerSystem: No VillagerComponent found on ", interactable.name)
		return
	
	# Get the relationship component if it exists
	var relationship = villager.get_node_or_null("RelationshipComponent")
	if relationship:
		var relationship_system = get_tree().get_first_node_in_group("relationship_system")
		if relationship_system:
			relationship_system.on_interaction(player, villager)
	
	# Start dialogue
	emit_signal("dialogue_started", villager)
	# Here you would typically start your dialogue system
	# For now, we'll just print a message
	print("Starting dialogue with ", villager.name)
