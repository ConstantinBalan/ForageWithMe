extends Node

const SAVE_PATH = "user://player_data.json"

var player_data = {
	"player": {
		"inventory": [],
		"recipes": [],
		"unlocked_tools": [],
		"relationships": {},
		"foraging_proficiency": {
			"berries": 0.0,
			"mushrooms": 0.0,
			"herbs": 0.0,
			"wood": 0.0
		},
		"completed_tutorials": {}
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

func update_foraging_proficiency(category: String, success_score: float) -> void:
	var current_prof = player_data["player"]["foraging_proficiency"].get(category, 0.0)
	# Increase proficiency more on success, decrease slightly on failure
	var delta = success_score * 0.1 if success_score > 0 else -0.05
	player_data["player"]["foraging_proficiency"][category] = clamp(current_prof + delta, 0.0, 1.0)
	save_game_data()

func get_foraging_proficiency(category: String) -> float:
	return player_data["player"]["foraging_proficiency"].get(category, 0.0)

func get_completed_tutorials() -> Dictionary:
	return player_data["player"]["completed_tutorials"]

func save_tutorial_completion(tutorial_id: String) -> void:
	player_data["player"]["completed_tutorials"][tutorial_id] = true
	save_game_data()
