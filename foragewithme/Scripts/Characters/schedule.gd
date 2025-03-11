### Schedule.gd
# Manages time-based activities and routines for villagers
#
# Called by:
# - AIController.gd (to determine current and next activities)
# - Villager.gd (for initialization)
#
# Emits signals to:
# - AIController.gd (activity_changed)
###
extends Node

class_name Schedule

# Dictionary mapping time slots to activities
# Format: { "day_season_hour": { type: "", location: Vector3, target: Node, duration: float } }
var scheduled_activities = {}

# Current activity
var current_activity = null
var current_activity_start_time = 0

signal activity_changed(new_activity)

### initialize_for_villager
# Sets up the schedule based on a specific villager's data
# Creates default and special schedules based on the villager's profession and preferences
#
# Parameters:
# - villager_id: String identifier for the villager
###
func initialize_for_villager(villager_id: String) -> void:
	var villager_data = ResourceLoader.get_villager(villager_id)
	if not villager_data:
		print("Schedule: Cannot initialize schedule, villager data not found for " + villager_id)
		return
		
	# Default schedule
	create_default_schedule(villager_data)
	
	# Special schedule overrides
	create_special_schedules(villager_data)
	
	print("Schedule initialized for " + villager_id + " with " + str(scheduled_activities.size()) + " activities")

### create_default_schedule
# Creates a standard daily schedule based on the villager's profession
# Sets up morning routine, work hours, and evening activities
#
# Parameters:
# - villager_data: VillagerData resource for this villager
###
func create_default_schedule(villager_data: VillagerData) -> void:
	# Morning routine
	add_activity("*_*_6", "wake_up", villager_data.home_location, null, 1)
	add_activity("*_*_7", "eat", villager_data.home_location, null, 1)
	
	# Work hours depend on profession
	match villager_data.profession:
		"farmer":
			add_activity("*_*_8", "work", villager_data.work_location, null, 6)
		"merchant":
			add_activity("*_*_9", "work", villager_data.work_location, null, 8)
		"artisan":
			add_activity("*_*_8", "work", villager_data.work_location, null, 5)
			add_activity("*_*_14", "gather", Vector3(-10, 0, 15), null, 2)
		"forager":
			add_activity("*_*_8", "gather", Vector3(10, 0, 10), null, 4)
			add_activity("*_*_13", "work", villager_data.work_location, null, 4)
	
	# Evening routine
	add_activity("*_*_18", "socialize", Vector3(0, 0, 0), null, 2)
	add_activity("*_*_20", "eat", villager_data.home_location, null, 1)
	add_activity("*_*_22", "sleep", villager_data.home_location, null, 8)

### create_special_schedules
# Adds special activities that override the default schedule
# Includes weekend activities and seasonal preferences
#
# Parameters:
# - villager_data: VillagerData resource for this villager
###
func create_special_schedules(villager_data: VillagerData) -> void:
	# Special weekend activities
	if villager_data.likes_festivals:
		add_activity("*_*_10", "festival", Vector3(0, 0, 0), null, 5, 7)  # Day 7 = weekend
	
	# Seasonal activities
	match villager_data.favorite_season:
		"Spring":
			add_activity("*_Spring_14", "garden", Vector3(5, 0, 5), null, 3)
		"Summer":
			add_activity("*_Summer_14", "swim", Vector3(15, 0, -10), null, 3)
		"Fall":
			add_activity("*_Fall_14", "forage", Vector3(-15, 0, -5), null, 3)
		"Winter":
			add_activity("*_Winter_14", "stay_warm", villager_data.home_location, null, 3)

### add_activity
# Adds an activity to the schedule at a specific time slot
# Time key format: "day_season_hour" with wildcards (*) supported
#
# Parameters:
# - time_key: The time slot for this activity
# - type: The type of activity (e.g. "work", "eat", etc.)
# - location: Vector3 position where the activity takes place
# - target: Optional Node reference for activities that involve another entity
# - duration: How long the activity lasts in hours
# - day: Optional specific day to override the day in time_key
###
func add_activity(time_key: String, type: String, location: Vector3, target = null, duration: float = 1.0, day = null) -> void:
	var activity = {
		"type": type,
		"location": location,
		"target": target,
		"duration": duration,
		"added_at": Time.get_unix_time_from_system()
	}
	
	if day != null:
		# Replace * in day position with actual day
		var parts = time_key.split("_")
		parts[0] = str(day)
		time_key = "_".join(parts)
	
	scheduled_activities[time_key] = activity

### get_current_activity
# Determines the current activity based on game time
# Checks from most specific to least specific time keys
#
# Returns:
# - Dictionary containing activity details, or empty if no activity is scheduled
###
func get_current_activity() -> Dictionary:
	var time_manager = get_node("/root/TimeManager")
	if not time_manager:
		print("Schedule: TimeManager not found")
		return {}
	
	var day = time_manager.current_day
	var season = time_manager.get_season_name()
	var hour = time_manager.current_hour
	
	# Generate time keys from most to least specific
	var time_keys = [
		"%d_%s_%d" % [day, season, hour],  # Specific day, season, hour
		"*_%s_%d" % [season, hour],        # Any day in this season at this hour
		"%d_*_%d" % [day, hour],           # This day of any season at this hour
		"*_*_%d" % [hour]                  # Any day, any season, at this hour
	]
	
	# Check for activities in order of specificity
	for key in time_keys:
		if scheduled_activities.has(key):
			if current_activity != scheduled_activities[key]:
				current_activity = scheduled_activities[key]
				current_activity_start_time = Time.get_unix_time_from_system()
				emit_signal("activity_changed", current_activity)
			return current_activity
	
	# No activity scheduled, return an empty dictionary
	if current_activity != null:
		current_activity = null
		emit_signal("activity_changed", null)
	
	return {}

### is_current_activity_valid
# Checks if the current activity is still valid (within its duration)
#
# Returns:
# - bool: true if the activity is still valid, false otherwise
###
func is_current_activity_valid() -> bool:
	if current_activity == null:
		return false
	
	var elapsed_time = Time.get_unix_time_from_system() - current_activity_start_time
	var duration_in_seconds = current_activity.duration * 60.0  # Convert minutes to seconds
	
	return elapsed_time <= duration_in_seconds

### get_next_activity
# Finds the next scheduled activity in the following 24 hours
# Handles day and season transitions
#
# Returns:
# - Dictionary containing next activity details, or empty if no activity is scheduled
###
func get_next_activity() -> Dictionary:
	var time_manager = get_node("/root/TimeManager")
	if not time_manager:
		return {}
	
	var day = time_manager.current_day
	var season = time_manager.get_season_name()
	var next_hour = time_manager.current_hour + 1
	
	# Check next 24 hours
	for i in range(1, 24):
		var hour_to_check = (time_manager.current_hour + i) % 24
		var day_to_check = day
		var season_to_check = season
		
		# If we cross into a new day
		if hour_to_check < time_manager.current_hour:
			day_to_check = (day % time_manager.DAYS_PER_SEASON) + 1
			
			# If we cross into a new season
			if day_to_check == 1 and day == time_manager.DAYS_PER_SEASON:
				var next_season_num = (time_manager.current_season + 1) % time_manager.SEASONS_PER_YEAR
				match next_season_num:
					0: season_to_check = "Spring"
					1: season_to_check = "Summer"
					2: season_to_check = "Fall"
					3: season_to_check = "Winter"
		
		# Check for activity at this future time
		var time_key = "%d_%s_%d" % [day_to_check, season_to_check, hour_to_check]
		if scheduled_activities.has(time_key):
			return scheduled_activities[time_key]
		
		# Check generic time keys too
		var generic_key = "*_%s_%d" % [season_to_check, hour_to_check]
		if scheduled_activities.has(generic_key):
			return scheduled_activities[generic_key]
		
		generic_key = "*_*_%d" % [hour_to_check]
		if scheduled_activities.has(generic_key):
			return scheduled_activities[generic_key]
	
	return {}

### add_temporary_activity
# Adds a one-time activity that overrides the regular schedule
# Used for special events or player interactions
#
# Parameters:
# - type: The type of activity
# - location: Vector3 position where the activity takes place
# - target: Optional Node reference for activities involving another entity
# - duration: How long the activity lasts in hours
###
func add_temporary_activity(type: String, location: Vector3, target = null, duration: float = 1.0) -> void:
	var activity = {
		"type": type,
		"location": location,
		"target": target,
		"duration": duration,
		"temporary": true,
		"added_at": Time.get_unix_time_from_system()
	}
	
	current_activity = activity
	current_activity_start_time = Time.get_unix_time_from_system()
	emit_signal("activity_changed", current_activity)

### clear_temporary_activities
# Removes all temporary activities, returning to the regular schedule
###
func clear_temporary_activities() -> void:
	current_activity = null
	emit_signal("activity_changed", null)
