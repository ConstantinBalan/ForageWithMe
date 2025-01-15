extends Node

@export var item_type: String = "Berries"
@export var quantity_available: int = 5
@export var respawn_time: float = 5.0
var last_foraged_time: float = 0.0

func _ready():
	print("ForageableComponent initialized with item: ", item_type, " (Quantity: ", quantity_available, ")")

func can_forage() -> bool:
	if quantity_available <= 0:
		print("No more ", item_type, " available")
		return false
	
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_foraged_time < respawn_time:
		print(item_type, " not ready yet. ", ceil(respawn_time - (current_time - last_foraged_time)), " seconds remaining")
		return false
		
	return true

func forage(amount: int = 1) -> Dictionary:
	if can_forage():
		var actual_amount = min(amount, quantity_available)
		quantity_available -= actual_amount
		last_foraged_time = Time.get_unix_time_from_system()
		print("Foraged ", actual_amount, " ", item_type, ". ", quantity_available, " remaining")
		return {"item_type": item_type, "quantity": actual_amount}
	return {}
