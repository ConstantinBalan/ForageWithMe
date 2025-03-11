### RelationshipTracker.gd
# Manages relationship values between the player and villagers
# Tracks friendship levels, gift preferences, and interaction limits
#
# Called by:
# - Villager.gd (for initialization)
# - DialogueSystem.gd (for relationship checks and changes)
# - QuestManager.gd (for relationship rewards)
#
# Emits signals to:
# - UI elements (relationship_changed, relationship_level_up)
###
extends Node

class_name RelationshipTracker

# Reference to parent villager
var villager: Villager

# Relationship value (0-100)
var relationship_value: float = 0.0

# Relationship events and their effects
var gift_effects = {
	"loved": 10.0,
	"liked": 5.0,
	"neutral": 2.0,
	"disliked": -3.0,
	"hated": -8.0
}

# Relationship levels and their thresholds
var relationship_levels = {
	"stranger": 0.0,
	"acquaintance": 15.0,
	"friend": 30.0,
	"good_friend": 50.0,
	"close_friend": 75.0,
	"best_friend": 90.0
}

# Daily interaction limit
var daily_interactions = 0
var max_daily_interactions = 3

signal relationship_changed(new_value, new_level)
signal relationship_level_up(new_level)

### _init
# Constructor that initializes the tracker with a reference to its parent villager
# Loads any existing relationship data from player save
#
# Parameters:
# - parent_villager: The Villager node this tracker belongs to
###
func _init(parent_villager: Villager):
	villager = parent_villager
	
	# Load initial value from PlayerDataManager if available
	load_relationship_data()

### _ready
# Called when the node enters the scene tree
# Connects necessary signals for day change tracking
###
func _ready():
	# Connect to necessary signals
	var time_manager = get_node("/root/TimeManager")
	if time_manager:
		time_manager.connect("day_changed", Callable(self, "_on_day_changed"))

### get_relationship_value
# Gets the current relationship value
#
# Returns:
# - float: Current relationship value (0-100)
###
func get_relationship_value() -> float:
	return relationship_value

### get_relationship_level
# Gets the current relationship level based on the relationship value
#
# Returns:
# - String: Current relationship level (e.g., "stranger", "friend", "best_friend")
###
func get_relationship_level() -> String:
	var current_level = "stranger"
	
	for level in relationship_levels.keys():
		if relationship_value >= relationship_levels[level]:
			current_level = level
	
	return current_level

### adjust_relationship
# Adjusts the relationship value by a specified amount
# Applies diminishing returns if daily interaction limit is exceeded
# Emits signals when relationship value or level changes
#
# Parameters:
# - amount: Float value to adjust relationship by (positive or negative)
###
func adjust_relationship(amount: float) -> void:
	if daily_interactions >= max_daily_interactions and amount > 0:
		# Diminishing returns after exceeding daily interaction limit
		amount *= 0.25
	
	var old_level = get_relationship_level()
	var old_value = relationship_value
	
	relationship_value = clamp(relationship_value + amount, 0.0, 100.0)
	daily_interactions += 1
	
	# Save the updated relationship value
	save_relationship_data()
	
	emit_signal("relationship_changed", relationship_value, get_relationship_level())
	
	# Check if level increased
	var new_level = get_relationship_level()
	if new_level != old_level and relationship_levels[new_level] > relationship_levels[old_level]:
		emit_signal("relationship_level_up", new_level)
		print("Relationship with " + villager.villager_data.name + " leveled up to " + new_level)

### receive_gift
# Processes the effect of giving a gift to this villager
# Determines preference and adjusts relationship accordingly
#
# Parameters:
# - gift_item: Dictionary containing gift item data
#
# Returns:
# - float: The effect the gift had on the relationship
###
func receive_gift(gift_item: Dictionary) -> float:
	var item_id = gift_item.id
	var preference = get_gift_preference(item_id)
	var effect = gift_effects[preference]
	
	adjust_relationship(effect)
	return effect

### get_gift_preference
# Determines the villager's preference for a specific gift item
# Checks against the villager's predefined preferences
#
# Parameters:
# - item_id: String identifier for the gift item
#
# Returns:
# - String: Preference level ("loved", "liked", "neutral", "disliked", or "hated")
###
func get_gift_preference(item_id: String) -> String:
	# Get villager preferences from their data
	var preferences = villager.villager_data.gift_preferences
	
	if preferences.loved.has(item_id):
		return "loved"
	elif preferences.liked.has(item_id):
		return "liked"
	elif preferences.disliked.has(item_id):
		return "disliked"
	elif preferences.hated.has(item_id):
		return "hated"
	else:
		return "neutral"

### _on_day_changed
# Signal callback for when the day changes
# Resets daily interaction counter
#
# Parameters:
# - _day: Integer representing the new day
# - _season: String representing the current season
# - _year: Integer representing the current year
###
func _on_day_changed(_day, _season, _year) -> void:
	daily_interactions = 0

### get_serialized_data
# Gets serialized relationship data for saving
#
# Returns:
# - Dictionary: Relationship data
###
func get_serialized_data() -> Dictionary:
	return {
		"value": relationship_value,
		"daily_interactions": daily_interactions
	}

### load_relationship_data
# Loads relationship data from player save
# Retrieves stored relationship values from PlayerDataManager
###
func load_relationship_data() -> void:
	var player_data_manager = get_node("/root/PlayerDataManager")
	if player_data_manager:
		var relationships = player_data_manager.player_data.player.relationships
		var villager_id = villager.villager_data.id
		
		if relationships.has(villager_id):
			relationship_value = relationships[villager_id].value
			daily_interactions = relationships[villager_id].daily_interactions
	else:
		print("RelationshipTracker: PlayerDataManager not found")

### save_relationship_data
# Saves relationship data to player save
# Updates the player's relationship data with this villager
###
func save_relationship_data() -> void:
	var player_data_manager = get_node("/root/PlayerDataManager")
	if player_data_manager:
		var villager_id = villager.villager_data.id
		player_data_manager.player_data.player.relationships[villager_id] = get_serialized_data()
	else:
		print("RelationshipTracker: PlayerDataManager not found")
