### TimeManager.gd
# Singleton that manages the game's time system including day/night cycle and seasons
# Controls the flow of time and notifies other systems of time changes
#
# Called by:
# - GameManager.gd (for initialization and time flow control)
# - Any script that needs to check current time
#
# Emits signals to:
# - Weather system (day/season changes)
# - Lighting system (time of day changes)
# - NPC schedulers (time changes)
# - Farming systems (season changes)
# - UI elements (time display updates)
###
extends Node

# Time signals
signal time_changed(time_of_day, minutes, hours, day, season, year)
signal day_changed(new_day, season, year)
signal season_changed(new_season, year)
signal year_changed(new_year)

# Time constants
const MINUTES_PER_HOUR = 60
const HOURS_PER_DAY = 24
const DAYS_PER_SEASON = 7
const SEASONS_PER_YEAR = 4
const TIME_SCALE = 30.0 # 1 real-second = 30 in-game minutes

# Time tracking
var current_minute: int = 0
var current_hour: int = 6 # Game starts at 6:00 AM
var current_day: int = 1
var current_season: int = 0 # 0: Spring, 1: Summer, 2: Fall, 3: Winter
var current_year: int = 1

# Time flow control
var time_paused: bool = false
var time_scale: float = 1.0 # 1.0 = normal speed
var ticks_per_minute: float = 1.0 # How many real seconds per game minute
var elapsed_ticks: float = 0.0

# Day/night cycle
var day_start_hour: int = 6 # 6 AM
var night_start_hour: int = 20 # 8 PM

# Time of day periods
var time_of_day: String = "Morning" # Morning, Afternoon, Evening, Night
var active_hours = {
	"start": 6, # 6:00 AM
	"end": 22 # 10:00 PM
}

# Weather system
var current_weather: String = "Sunny"
var possible_weather = ["Sunny", "Cloudy", "Rainy", "Foggy", "Stormy"]
var weather_chances = {
	"Spring": {"Sunny": 0.4, "Cloudy": 0.3, "Rainy": 0.2, "Foggy": 0.1, "Stormy": 0.0},
	"Summer": {"Sunny": 0.7, "Cloudy": 0.1, "Rainy": 0.1, "Foggy": 0.0, "Stormy": 0.1},
	"Fall": {"Sunny": 0.3, "Cloudy": 0.4, "Rainy": 0.2, "Foggy": 0.1, "Stormy": 0.0},
	"Winter": {"Sunny": 0.2, "Cloudy": 0.5, "Rainy": 0.0, "Foggy": 0.3, "Stormy": 0.0}
}

### _ready
# Called when the node enters the scene tree
# Initializes the time system
###
func _ready():
	# Initialize with starting time
	update_time_of_day()
	emit_signal("time_changed",
		time_of_day,
		current_minute,
		current_hour,
		current_day,
		get_season_name(),
		current_year)
	emit_signal("day_changed", current_day, get_season_name(), current_year)
	emit_signal("season_changed", get_season_name(), current_year)
	emit_signal("year_changed", current_year)

### _process
# Called every frame to update the time system
# Updates game time based on real time elapsed
#
# Parameters:
# - delta: Time elapsed since the previous frame
###
func _process(delta: float) -> void:
	if time_paused:
		return

	# Update elapsed time
	elapsed_ticks += delta * time_scale

	# Check if a minute has passed
	if elapsed_ticks >= ticks_per_minute:
		# Time for a new minute
		elapsed_ticks -= ticks_per_minute
		update_time(delta)

### update_time
# Main time update function
# Updates game time based on real time elapsed
#
# Parameters:
# - delta: Time elapsed since the previous frame
###
func update_time(delta: float) -> void:
	current_minute += int(delta * TIME_SCALE)

	if current_minute >= MINUTES_PER_HOUR:
		current_minute = 0
		current_hour += 1
		update_time_of_day()

	if current_hour >= HOURS_PER_DAY:
		current_hour = 0
		current_day += 1
		emit_signal("day_changed", current_day, get_season_name(), current_year)
		update_weather()

	if current_day > DAYS_PER_SEASON:
		current_day = 1
		current_season += 1
		emit_signal("season_changed", get_season_name(), current_year)

	if current_season >= SEASONS_PER_YEAR:
		current_season = 0
		current_year += 1
		emit_signal("year_changed", current_year)

	emit_signal("time_changed",
		time_of_day,
		current_minute,
		current_hour,
		current_day,
		get_season_name(),
		current_year)

### update_time_of_day
# Update the time of day period based on current hour
###
func update_time_of_day() -> void:
	var old_time = time_of_day

	if current_hour >= 5 and current_hour < 12:
		time_of_day = "Morning"
	elif current_hour >= 12 and current_hour < 17:
		time_of_day = "Afternoon"
	elif current_hour >= 17 and current_hour < 20:
		time_of_day = "Evening"
	else:
		time_of_day = "Night"

	if old_time != time_of_day:
		print("Time of day changed to: " + time_of_day)

### update_weather
# Update weather with probabilistic model
###
func update_weather() -> void:
	var season_name = get_season_name()
	var chances = weather_chances[season_name]

	var rand_val = randf()
	var cumulative = 0.0

	for weather in possible_weather:
		cumulative += chances[weather]
		if rand_val <= cumulative:
			current_weather = weather
			print("Weather changed to: " + current_weather)
			break

### get_season_name
# Gets the name of the current season
#
# Returns:
# - String: "Spring", "Summer", "Fall", or "Winter"
###
func get_season_name() -> String:
	match current_season:
		0: return "Spring"
		1: return "Summer"
		2: return "Fall"
		3: return "Winter"
		_: return "Unknown"

### is_active_hours
# Check if it's active hours (6:00 AM to 10:00 PM)
#
# Returns:
# - bool: True if it's active hours, false otherwise
###
func is_active_hours() -> bool:
	return current_hour >= active_hours.start and current_hour < active_hours.end

### get_formatted_time
# Gets a formatted string representation of the current time
#
# Returns:
# - String: Formatted time string
###
func get_formatted_time() -> String:
	var am_pm = "AM" if current_hour < 12 else "PM"
	var hour_12 = current_hour if current_hour <= 12 else current_hour - 12
	if hour_12 == 0:
		hour_12 = 12
	return "%d:%02d %s" % [hour_12, current_minute, am_pm]

### get_formatted_date
# Gets a formatted string representation of the current date
#
# Returns:
# - String: Formatted date string
###
func get_formatted_date() -> String:
	return "Day %d of %s, Year %d" % [current_day, get_season_name(), current_year]

### get_serialized_data
# Serialize time data for saving
#
# Returns:
# - Dictionary: Time data for saving
###
func get_serialized_data() -> Dictionary:
	return {
		"minute": current_minute,
		"hour": current_hour,
		"day": current_day,
		"season": current_season,
		"year": current_year,
		"weather": current_weather
	}

### load_from_data
# Load time data from saved data
#
# Parameters:
# - data: Dictionary containing saved time state data
###
func load_from_data(data: Dictionary) -> void:
	if data.has("minute"): current_minute = data.minute
	if data.has("hour"): current_hour = data.hour
	if data.has("day"): current_day = data.day
	if data.has("season"): current_season = data.season
	if data.has("year"): current_year = data.year
	if data.has("weather"): current_weather = data.weather
	
	update_time_of_day()
