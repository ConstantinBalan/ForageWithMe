extends Node

@export var item_type: String
@export var quantity_available: int = 1
@export var respawn_time: float = 60.0
var last_foraged_time: float = 0.0

func can_forage() -> bool:
	return quantity_available > 0 and (Time.get_unix_time_from_system() - last_foraged_time >= respawn_time)

func forage(amount: int = 1) -> Dictionary:
	if can_forage():
		var actual_amount = min(amount, quantity_available)
		quantity_available -= actual_amount
		last_foraged_time = Time.get_unix_time_from_system()
		return { "item_type": item_type, "quantity": actual_amount }
	return {}
