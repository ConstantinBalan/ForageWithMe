extends Node

@export var item_type: String = "Berries"
@export var quantity_available: int = 5
@export var respawn_time: float = 5.0
var last_foraged_time: float = 0.0

func _ready():
	add_to_group("forageable_component")
	print("ForageableComponent initialized with item: ", item_type, " (Quantity: ", quantity_available, ")")
