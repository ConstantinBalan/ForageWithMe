extends Node

const SAVE_PATH = "user://player_data.json"

var player_data = {
	"player": {
		"inventory": [],
		"recipes": [],
		"unlocked_tools": [],
		"relationships": {}
	},
	"villagers": {},
	"cabin": {},
	"world_state": {}
}

func save_game_data():
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		if player is Player:  # Check if it's our Player class
			# Save inventory data directly from player
			player_data["player"]["inventory"] = player.inventory if "inventory" in player else []
			player_data["player"]["recipes"] = player.recipes if "recipes" in player else []
			player_data["player"]["unlocked_tools"] = player.unlocked_tools if "unlocked_tools" in player else []
			player_data["player"]["relationships"] = player.relationships if "relationships" in player else {}

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
				if player is Player:  # Check if it's our Player class
					# Load data directly into player properties
					if "inventory" in player_data["player"]:
						player.inventory = player_data["player"]["inventory"]
					if "recipes" in player_data["player"]:
						player.recipes = player_data["player"]["recipes"]
					if "unlocked_tools" in player_data["player"]:
						player.unlocked_tools = player_data["player"]["unlocked_tools"]
					if "relationships" in player_data["player"]:
						player.relationships = player_data["player"]["relationships"]
					
					# Emit any necessary signals
					player.emit_signal("inventory_changed") if "inventory_changed" in player.get_signal_list() else null
		else:
			printerr("Error loading game data: Invalid save file format.")
		file.close()
	else:
		printerr("No existing save data found at %s" % SAVE_PATH)
