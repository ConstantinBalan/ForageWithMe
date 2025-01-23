extends Entity

var inventory = {}

func _ready():
	print("Villager is ready.")

func interact(player):
	print("Villager interacted with.")
	# Example: Increase player's relationship with this villager
	player.get_component("RelationshipComponent").adjust_relationship(name, 5)
