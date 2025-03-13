### QuestManager.gd
# Singleton that manages all quest-related functionality in the game
# Tracks active quests, handles updates, completions, and failures
#
# Called by:
# - GameManager.gd (for initialization)
# - Player.gd (for quest updates and turn-ins)
# - VillagerManager.gd (for quest assignments)
# - UI scripts (for displaying quest information)
#
# Emits signals to:
# - UI elements (quest_added, quest_updated, quest_completed, quest_failed)
# - PlayerDataManager (for reward processing)
###
extends Node

signal quest_added(quest_id)
signal quest_updated(quest_id, progress)
signal quest_completed(quest_id, rewards)
signal quest_failed(quest_id)

# Dictionary of all available quests
var available_quests = {}

# Dictionary of active quests: quest_id -> quest_data
var active_quests = {}

# Dictionary of completed quests: quest_id -> completion_data
var completed_quests = {}

# Dictionary of failed quests: quest_id -> failure_data
var failed_quests = {}

### _ready
# Called when the node enters the scene tree
# Initializes references and connects signals
###
func _ready():
	# Connect to necessary signals
	pass

### load_available_quests
# Load available quests from resources
#
# This would normally load from a data file or resources
###
func load_available_quests():
	# This would normally load from a data file or resources
	print("Loading available quests")
	# In a real implementation, we'd load from JSON or resource files

### add_quest
# Adds a new quest to active quests
#
# Parameters:
# - quest_id: String identifier for the quest to add
#
# Returns:
# - bool: True if quest was successfully added, false otherwise
###
func add_quest(quest_id: String) -> bool:
	if active_quests.has(quest_id) or completed_quests.has(quest_id):
		print("Quest already active or completed: " + quest_id)
		return false

	if available_quests.has(quest_id):
		var quest_data = available_quests[quest_id].duplicate()
		quest_data.progress = 0
		quest_data.started_at = Time.get_unix_time_from_system()
		active_quests[quest_id] = quest_data

		quest_added.emit(quest_id)
		print("Quest added: " + quest_id)
		return true
	print("Quest not found: " + quest_id)
	return false

### update_quest_progress
# Updates progress on a quest
#
# Parameters:
# - quest_id: String identifier for the quest
# - progress_amount: Integer amount to increment progress by
#
# Returns:
# - bool: True if the progress was successfully updated, false otherwise
###
func update_quest_progress(quest_id: String, progress_amount: int) -> bool:
	if not active_quests.has(quest_id):
		print("Attempt to update non-active quest: " + quest_id)
		return false

	var quest = active_quests[quest_id]
	quest.progress += progress_amount

	quest_updated.emit(quest_id, quest.progress)
	print("Updated progress for quest %s: %d/%d" % [quest_id, quest.progress, quest.required_progress])

	# Check if quest is now complete
	if quest.progress >= quest.required_progress:
		complete_quest(quest_id)

	return true

### complete_quest
# Marks a quest as complete and gives rewards
#
# Parameters:
# - quest_id: String identifier for the completed quest
###
func complete_quest(quest_id: String) -> bool:
	if not active_quests.has(quest_id):
		print("Attempt to complete non-active quest: " + quest_id)
		return false

	var quest = active_quests[quest_id]
	var completion_data = {
		"completed_at": Time.get_unix_time_from_system(),
		"time_taken": Time.get_unix_time_from_system() - quest.started_at,
		"quest_data": quest
	}

	# Move from active to completed
	completed_quests[quest_id] = completion_data
	active_quests.erase(quest_id)

	# Handle rewards
	give_quest_rewards(quest.rewards)

	quest_completed.emit(quest_id, quest.rewards)
	print("Quest completed: " + quest_id)
	return true

### fail_quest
# Marks a quest as failed
#
# Parameters:
# - quest_id: String identifier for the failed quest
# - reason: String describing why the quest failed
###
func fail_quest(quest_id: String, reason: String = "") -> bool:
	if not active_quests.has(quest_id):
		print("Attempt to fail non-active quest: " + quest_id)
		return false

	var quest = active_quests[quest_id]
	var failure_data = {
		"failed_at": Time.get_unix_time_from_system(),
		"time_taken": Time.get_unix_time_from_system() - quest.started_at,
		"reason": reason,
		"quest_data": quest
	}

	# Move from active to failed
	failed_quests[quest_id] = failure_data
	active_quests.erase(quest_id)

	quest_failed.emit(quest_id)
	print("Quest failed: " + quest_id + (", Reason: " + reason if reason else ""))
	return true

### give_quest_rewards
# Process rewards for completed quests
#
# Parameters:
# - rewards: Dictionary of rewards to process
###
func give_quest_rewards(rewards: Dictionary) -> void:
	# Handle different types of rewards
	if rewards.has("items"):
		for item in rewards.items:
			if PlayerDataManager.add_item_to_inventory(item.id, item.quantity):
				print("Added reward item: %s x%d" % [item.id, item.quantity])

	if rewards.has("currency"):
		# If we had a currency system
		print("Added reward currency: %d" % rewards.currency)

	if rewards.has("experience"):
		# If we had an experience system
		print("Added reward experience: %d" % rewards.experience)

	if rewards.has("relationship"):
		for villager_id in rewards.relationship:
			var amount = rewards.relationship[villager_id]
			# This would call a function to update relationships
			print("Added relationship with %s: %d" % [villager_id, amount])

### is_quest_active
# Checks if a quest is active
#
# Parameters:
# - quest_id: String identifier for the quest
#
# Returns:
# - bool: True if the quest is active, false otherwise
###
func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

### is_quest_completed
# Checks if a quest is completed
#
# Parameters:
# - quest_id: String identifier for the quest
#
# Returns:
# - bool: True if the quest is completed, false otherwise
###
func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

### is_quest_failed
# Checks if a quest is failed
#
# Parameters:
# - quest_id: String identifier for the quest
#
# Returns:
# - bool: True if the quest is failed, false otherwise
###
func is_quest_failed(quest_id: String) -> bool:
	return failed_quests.has(quest_id)

### get_quest_progress
# Gets progress for a quest
#
# Parameters:
# - quest_id: String identifier for the quest
#
# Returns:
# - int: Progress of the quest
###
func get_quest_progress(quest_id: String) -> int:
	if active_quests.has(quest_id):
		return active_quests[quest_id].progress
	return -1

### get_quest_details
# Gets quest details
#
# Parameters:
# - quest_id: String identifier for the quest
#
# Returns:
# - Dictionary: Quest details
###
func get_quest_details(quest_id: String) -> Dictionary:
	if available_quests.has(quest_id):
		return available_quests[quest_id]
	return {}

### get_serialized_data
# Gets serialized data for saving
#
# Returns:
# - Dictionary: Serialized data
###
func get_serialized_data() -> Dictionary:
	return {
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"failed_quests": failed_quests
	}

### load_from_data
# Loads from serialized data
#
# Parameters:
# - data: Dictionary containing serialized data
###
func load_from_data(data: Dictionary) -> void:
	if data.has("active_quests"): active_quests = data.active_quests
	if data.has("completed_quests"): completed_quests = data.completed_quests
	if data.has("failed_quests"): failed_quests = data.failed_quests
