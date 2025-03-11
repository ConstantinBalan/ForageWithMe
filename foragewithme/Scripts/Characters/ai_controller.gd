### AIController.gd
# Controls the behavior and decision-making for villager NPCs
#
# Called by:
# - Villager.gd (for initialization and updates)
# - WorldManager.gd (for event notifications)
#
# Emits signals to:
# - Villager.gd (state_changed)
# - Interacts with DialogueSystem.gd and Schedule.gd
###
class_name AIController
extends Node

signal state_changed(new_state)

# Reference to the parent villager node
var villager: Villager
var current_state: String = "idle"
var current_target: Node = null
var current_path: Array = []
var path_index: int = 0

# States
enum AIState {
	IDLE,
	WALKING,
	WORKING,
	TALKING,
	RESTING
}

# Current behavior and state
var state: AIState = AIState.IDLE
var schedule: Schedule
var interaction_range: float = 2.0
var thinking_time: float = 0.0
var decision_interval: float = 1.0 # How often to make decisions

### _init
# Constructor that initializes the controller with a reference to its parent villager
#
# Parameters:
# - parent_villager: The Villager node this AI controls
###
func _init(parent_villager: Villager):
	villager = parent_villager

### _ready
# Called when the node enters the scene tree
# Initializes the schedule and connects necessary signals
###
func _ready():
	# Initialize schedule
	schedule = Schedule.new()
	schedule.initialize_for_villager(villager.villager_data.id)

### _process
# Called every frame to update AI behavior
# Handles decision-making timing and processes the current state
#
# Parameters:
# - delta: Time elapsed since the previous frame
###
func _process(delta):
	# Update thinking time
	thinking_time += delta

	# Only make decisions at certain intervals
	if thinking_time >= decision_interval:
		make_decision()
		thinking_time = 0.0

	# Process the current state
	match state:
		AIState.IDLE:
			process_idle_state(delta)
		AIState.WALKING:
			process_walking_state(delta)
		AIState.WORKING:
			process_working_state(delta)
		AIState.TALKING:
			process_talking_state(delta)
		AIState.RESTING:
			process_resting_state(delta)

### make_decision
# Main decision-making function that determines the villager's next action
# Prioritizes scheduled activities, then falls back to random behavior
###
func make_decision():
	# Check schedule first
	var scheduled_activity = schedule.get_current_activity()
	if scheduled_activity:
		handle_scheduled_activity(scheduled_activity)
		return

	# If no scheduled activity, use behavior patterns
	var rand = randf()

	if rand < 0.1: # 10% chance to change state when no schedule
		var new_state = randi() % AIState.size()
		change_state(new_state)

### handle_scheduled_activity
# Processes a scheduled activity from the villager's schedule
# Moves the villager to the appropriate location and changes state
#
# Parameters:
# - activity: Dictionary containing activity details
###
func handle_scheduled_activity(activity: Dictionary):
	match activity.type:
		"work":
			move_to_location(activity.location)
			if villager.global_position.distance_to(activity.location) < interaction_range:
				change_state(AIState.WORKING)
		"rest":
			move_to_location(activity.location)
			if villager.global_position.distance_to(activity.location) < interaction_range:
				change_state(AIState.RESTING)
		"socialize":
			# Find the target villager or player
			var target = activity.target
			if target:
				move_to_target(target)
				if villager.global_position.distance_to(target.global_position) < interaction_range:
					change_state(AIState.TALKING)

### process_idle_state
# Handles behavior when in the IDLE state
# Villager stands around, occasionally plays idle animations
#
# Parameters:
# - _delta: Time elapsed since the previous frame (unused)
###
func process_idle_state(_delta):
	# Just stand around, occasionally look around
	if randf() < 0.05: # 5% chance per process call to play idle animation
		villager.play_animation("idle_look_around")

### process_walking_state
# Handles behavior when in the WALKING state
# Moves the villager along the current path
#
# Parameters:
# - _delta: Time elapsed since the previous frame (unused)
###
func process_walking_state(_delta):
	if current_path.size() == 0 or path_index >= current_path.size():
		# Path is complete
		change_state(AIState.IDLE)
		return

	# Move along path
	var target_point = current_path[path_index]
	var direction = (target_point - villager.global_position).normalized()
	villager.move_in_direction(direction)

	# Check if reached current waypoint
	if villager.global_position.distance_to(target_point) < 0.5:
		path_index += 1

### process_working_state
# Handles behavior when in the WORKING state
# Plays working animations and checks if work time is finished
#
# Parameters:
# - _delta: Time elapsed since the previous frame (unused)
###
func process_working_state(_delta):
	# Play working animation
	villager.play_animation("working")

	# Check if work time is finished from schedule
	if not schedule.is_current_activity_valid():
		change_state(AIState.IDLE)

### process_talking_state
# Handles behavior when in the TALKING state
# Makes the villager face the conversation target
#
# Parameters:
# - _delta: Time elapsed since the previous frame (unused)
###
func process_talking_state(_delta):
	# Face the target if there is one
	if current_target:
		villager.face_direction(current_target.global_position - villager.global_position)

	# Check if conversation should end
	if not current_target or not schedule.is_current_activity_valid():
		change_state(AIState.IDLE)

### process_resting_state
# Handles behavior when in the RESTING state
# Plays resting animations and checks if rest time is finished
#
# Parameters:
# - _delta: Time elapsed since the previous frame (unused)
###
func process_resting_state(_delta):
	# Play resting animation
	villager.play_animation("resting")

	# Check if rest time is finished
	if not schedule.is_current_activity_valid():
		change_state(AIState.IDLE)

### change_state
# Changes the AI state and plays the corresponding animation
#
# Parameters:
# - new_state: Integer from AIState enum representing the new state
###
func change_state(new_state: int):
	state = new_state

	match state:
		AIState.IDLE:
			villager.play_animation("idle")
		AIState.WALKING:
			villager.play_animation("walk")
		AIState.WORKING:
			villager.play_animation("work")
		AIState.TALKING:
			villager.play_animation("talk")
		AIState.RESTING:
			villager.play_animation("rest")
	
	emit_signal("state_changed", state)

### set_path
# Sets the movement path for the villager and starts walking
#
# Parameters:
# - path: Array of Vector3 points forming the path to follow
###
func set_path(path: Array):
	current_path = path
	path_index = 0

	if path.size() > 0:
		change_state(AIState.WALKING)

### move_to_location
# Navigates the villager to a specific location
# In a full implementation, would use the navigation mesh
#
# Parameters:
# - location: Vector3 position to move to
###
func move_to_location(location: Vector3):
	# This would use navigation mesh in full implementation
	var path = [location] # Simplified - in real game would request path from navigation
	set_path(path)

### move_to_target
# Moves the villager toward a target node
#
# Parameters:
# - target: Node to move toward (typically another character)
###
func move_to_target(target: Node):
	current_target = target
	move_to_location(target.global_position)

### interact_with_player
# Handles player interaction with this villager
# Changes state to talking and initiates dialogue
#
# Parameters:
# - player: Player node that is interacting with this villager
###
func interact_with_player(player: Player):
	change_state(AIState.TALKING)
	current_target = player

	# Get dialogue system and start conversation
	var dialogue_system = villager.get_node_or_null("DialogueSystem")
	if dialogue_system:
		dialogue_system.start_dialogue_with_player(player)

### react_to_event
# Handles villager reactions to world events
# Different reactions based on event type
#
# Parameters:
# - event_type: String identifying the type of event
# - event_data: Dictionary containing event details
###
func react_to_event(event_type: String, event_data: Dictionary):
	match event_type:
		"player_nearby":
			# React to player being nearby
			var player = event_data.player
			if randf() < 0.3: # 30% chance to acknowledge player
				face_towards(player.global_position)
				villager.play_animation("wave")
		"weather_changed":
			# React to weather changes
			var weather = event_data.weather
			if weather == "Rainy" and state != AIState.RESTING:
				# Try to find shelter
				var shelter_location = find_nearest_shelter()
				if shelter_location:
					move_to_location(shelter_location)

### face_towards
# Utility function to make the villager face toward a position
#
# Parameters:
# - position: Vector3 position to face
###
func face_towards(position: Vector3):
	var direction = (position - villager.global_position).normalized()
	villager.face_direction(direction)

### find_nearest_shelter
# Finds the closest shelter location when needed (e.g., during bad weather)
# Placeholder implementation that would use a tag system in a real game
#
# Returns:
# - Vector3 position of the nearest shelter
###
func find_nearest_shelter() -> Vector3:
	# This is a placeholder - in a real implementation you would
	# query the world for shelter locations
	# For now we'll return a default position
	return Vector3(0, 0, 0)
