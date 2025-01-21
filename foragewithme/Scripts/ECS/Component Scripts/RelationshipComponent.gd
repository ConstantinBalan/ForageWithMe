extends Node

# Data-only component for storing relationship values
var relationships = {} # { "villager1": 75, "villager2": 20 }

func _ready():
	add_to_group("relationship_component")
