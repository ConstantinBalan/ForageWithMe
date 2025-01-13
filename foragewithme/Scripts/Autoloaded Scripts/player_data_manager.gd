extends Node

const SAVE_PATH = "user://player_data.json"

#Get/Set all player, NPC, world, save data from player_data
var player_data = {
	"player": {
		"inventory": [],
		"recipes": [],
		"unlocked_tools": []
	},
	"villagers": {
		
	},
	"cabin": {
		
	},
	"world_state": {
		
	}
}

func save_game_data():
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		if player.has_node("InventoryComponent") and player.has_node("RelationshipComponent"):
			player_data["inventory"] = player.get_node("InventoryComponent").items
			player_data["relationships"] = player.get_node("RelationshipComponent").relationships

			var json_string = JSON.stringify(player_data, "\t")
			var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
			if file:
				file.store_string(json_string)
				file.close()
				print("Game data saved to %s" % SAVE_PATH)
			else:
				printerr("Error saving game data to %s" % SAVE_PATH)

func load_game_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var loaded_data = JSON.parse_string(json_string)
		if loaded_data != null and typeof(loaded_data) == TYPE_DICTIONARY:
			player_data = loaded_data
			if get_tree().has_group("player"):
				var player = get_tree().get_nodes_in_group("player")[0]
				if player.has_node("InventoryComponent"):
					player.get_node("InventoryComponent").items = player_data.inventory
					player.get_node("InventoryComponent").emit_signal("inventory_changed")
				if player.has_node("RelationshipComponent"):
					player.get_node("RelationshipComponent").relationships = player_data.relationships
		else:
			printerr("Error loading game data: Invalid save file format.")
		file.close()
	else:
		printerr("No existing save data found at %s" % SAVE_PATH)
