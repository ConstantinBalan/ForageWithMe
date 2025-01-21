extends Node

var items = {} # { "wood": 10, "berries": 5 }

func _ready():
	add_to_group("inventory_component")
