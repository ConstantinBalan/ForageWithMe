### DialogueSystem.gd
# Manages dialogue interactions between villagers and the player
#
# Called by:
# - Villager.gd (through AIController)
# - UI/DialogueUI.gd (for player response selection)
#
# Emits signals to:
# - UI/DialogueUI.gd (dialogue_started, dialogue_ended, dialogue_response_selected)
# - RelationshipTracker.gd (indirectly through function calls)
###
class_name DialogueSystem
extends Node

signal dialogue_started(villager_id)
signal dialogue_ended(villager_id)
signal dialogue_response_selected(response_index)

# Reference to parent villager
var villager: Villager
var player: Player
var current_dialogue: DialogueData
var dialogue_state: String = "inactive"
var current_dialogue_options = []
var relationship_tracker: RelationshipTracker

### _init
# Constructor that initializes the DialogueSystem with a reference to its parent villager
# and creates a new RelationshipTracker for that villager
#
# Parameters:
# - parent_villager: The Villager node that owns this dialogue system
###
func _init(parent_villager: Villager):
	villager = parent_villager
	relationship_tracker = RelationshipTracker.new(villager)

### _ready
# Called when the node enters the scene tree
# Initializes the system and connects necessary signals
###
func _ready():
	# Initialize system and connect signals
	pass

### start_dialogue_with_player
# Begins a dialogue interaction between the villager and player
# Gets appropriate dialogue options and displays the initial dialogue
#
# Parameters:
# - player_ref: Reference to the Player node interacting with this villager
###
func start_dialogue_with_player(player_ref: Player) -> void:
	player = player_ref
	dialogue_state = "active"

	# Get dialogue options based on relationship level, time of day, etc.
	var dialogue_options = get_dialogue_options()

	if dialogue_options.size() > 0:
		current_dialogue = dialogue_options[0] # Pick first for now, could be randomized
		emit_signal("dialogue_started", villager.villager_data.id)

		# Display initial dialogue
		display_current_dialogue()
	else:
		print("DialogueSystem: No dialogue options available")
		end_dialogue()

### get_dialogue_options
# Retrieves available dialogue options based on current context
# Filters dialogues by time of day, season, relationship level, and whether they've been seen
#
# Returns:
# - Array of DialogueData resources that are valid for the current context
###
func get_dialogue_options() -> Array:
	var options = []

	# Get time-specific dialogue
	var time_manager = get_node("/root/TimeManager")
	if time_manager:
		var time_of_day = time_manager.time_of_day
		var season = time_manager.get_season_name()

		# Get dialogues for this villager
		var villager_dialogues = ResourceLoader.get_dialogues_for_villager(villager.villager_data.id)

		# Filter by time of day and season if applicable
		for dialogue in villager_dialogues:
			var is_valid = true

			# Check time of day constraint
			if dialogue.time_of_day != "" and dialogue.time_of_day != time_of_day:
				is_valid = false

			# Check season constraint
			if dialogue.season != "" and dialogue.season != season:
				is_valid = false

			# Check relationship level constraint
			var relationship_level = relationship_tracker.get_relationship_level()
			if dialogue.min_relationship_level > relationship_level:
				is_valid = false

			# Check if this dialogue has already been seen and shouldn't repeat
			if dialogue.one_time_only and dialogue.has_been_seen:
				is_valid = false

			if is_valid:
				options.append(dialogue)

	return options

### display_current_dialogue
# Shows the current dialogue text and response options to the player
# Processes any variables in the text and updates the UI
#
# If no current dialogue exists, ends the dialogue session
###
func display_current_dialogue() -> void:
	if not current_dialogue:
		end_dialogue()
		return

	print("DialogueSystem: " + villager.villager_data.name + " says: " + current_dialogue.text)

	# Process any variables in the text
	var processed_text = process_dialogue_variables(current_dialogue.text)

	# Get responses
	current_dialogue_options = current_dialogue.responses

	# Display in UI
	# This would connect to a UI system to show the dialogue
	var dialogue_ui = get_tree().get_root().get_node_or_null("DialogueUI")
	if dialogue_ui:
		dialogue_ui.show_dialogue(villager.villager_data, processed_text, current_dialogue_options)
	else:
		# Debug display of options
		for i in range(current_dialogue_options.size()):
			print(str(i) + ": " + current_dialogue_options[i].text)

### process_dialogue_variables
# Replaces variable placeholders in dialogue text with actual values
# Currently supports {PLAYER_NAME}, {TIME}, and {SEASON}
#
# Parameters:
# - text: The original dialogue text with placeholders
#
# Returns:
# - String with all variables replaced by their actual values
###
func process_dialogue_variables(text: String) -> String:
	var processed = text

	# Replace player name
	processed = processed.replace("{PLAYER_NAME}", "Player")

	# Replace time
	var time_manager = get_node("/root/TimeManager")
	if time_manager:
		processed = processed.replace("{TIME}", time_manager.get_formatted_time())
		processed = processed.replace("{SEASON}", time_manager.get_season_name())

	return processed

### select_response
# Handles the player selecting a response option
# Applies relationship effects, and transitions to next dialogue if available
#
# Parameters:
# - response_index: The index of the selected response
###
func select_response(response_index: int) -> void:
	if response_index < 0 or response_index >= current_dialogue_options.size():
		print("DialogueSystem: Invalid response index")
		return

	var response = current_dialogue_options[response_index]
	emit_signal("dialogue_response_selected", response_index)

	# Apply relationship effects
	if response.relationship_effect != 0:
		relationship_tracker.adjust_relationship(response.relationship_effect)
		var message = (
			"Relationship with " + villager.villager_data.name +
			" changed by " + str(response.relationship_effect) +
			" to " + str(relationship_tracker.get_relationship_value())
		)
		print(message)

	# Check for next dialogue
	if response.next_dialogue_id != "":
		var next_dialogue = ResourceLoader.get_dialogue(response.next_dialogue_id)
		if next_dialogue:
			current_dialogue = next_dialogue
			display_current_dialogue()
			return

	# If there's no next dialogue, end the conversation
	end_dialogue()

### end_dialogue
# Terminates the current dialogue session
# Resets dialogue state and notifies the UI
###
func end_dialogue() -> void:
	dialogue_state = "inactive"
	current_dialogue = null
	current_dialogue_options = []
	emit_signal("dialogue_ended", villager.villager_data.id)

	# Hide dialogue UI
	var dialogue_ui = get_tree().get_root().get_node_or_null("DialogueUI")
	if dialogue_ui:
		dialogue_ui.hide_dialogue()

### mark_current_dialogue_as_seen
# Marks the current dialogue as seen so it won't be repeated if one_time_only is true
###
func mark_current_dialogue_as_seen() -> void:
	if current_dialogue and current_dialogue.one_time_only:
		current_dialogue.has_been_seen = true

### get_dialogue_state
# Returns the current state of the dialogue system
#
# Returns:
# - String: "active" if dialogue is ongoing, "inactive" otherwise
###
func get_dialogue_state() -> String:
	return dialogue_state

### is_dialogue_active
# Convenience function to check if dialogue is currently active
#
# Returns:
# - bool: true if dialogue is active, false otherwise
###
func is_dialogue_active() -> bool:
	return dialogue_state == "active"

### get_relationship_tracker
# Provides access to the RelationshipTracker for this villager
#
# Returns:
# - RelationshipTracker: The relationship tracker for this villager
###
func get_relationship_tracker() -> RelationshipTracker:
	return relationship_tracker