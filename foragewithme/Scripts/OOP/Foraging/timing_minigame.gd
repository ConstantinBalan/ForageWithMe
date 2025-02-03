extends ForagingMinigameBase
class_name TimingMinigame

@onready var progress_bar = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar
@onready var target_zone = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar/TargetZone
@onready var cursor = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar/Cursor
@onready var success_particles = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar/SuccessParticles
@onready var panel_container = $PanelContainer

var cursor_speed: float = 100.0 # Percentage per second
var cursor_position: float = 0.0 # 0 to 1
var last_cursor_position: float = 0.0 # Track previous position
var direction: int = 1
var target_zone_size: float
var target_zone_position: float
var is_active: bool = false
var shake_time: float = 0.0
var original_container_position: Vector2
var shake_direction: int = 1 # 1 or -1 for alternating shake

const MARGIN_OF_ERROR: float = 0.0 # 5% extra margin on each side
const RESULT_DISPLAY_TIME: float = 1.0 # Time to show result before ending minigame
const SUCCESS_DISPLAY_TIME: float = 1.5
const SHAKE_DURATION: float = 0.3 # Slightly faster shake
const SHAKE_MAGNITUDE: float = 8.0 # Slightly stronger shake
const SHAKE_FREQUENCY: float = 30.0 # Higher frequency for snappier shake
const POSITION_CHECK_STEPS: int = 10 # Number of intermediate positions to check

func _ready() -> void:
	# Wait for layout to be ready
	await get_tree().process_frame
	original_container_position = panel_container.position
	#_setup_minigame()
	

func _setup_minigame() -> void:
	print("TimingMinigame _setup_minigame called")
	print("Current difficulty:", difficulty)
	
	# Wait for layout to be ready and progress bar to have its final size
	#await get_tree().process_frame
	#await get_tree().process_frame # Sometimes need an extra frame
	
	# Set up target zone based on difficulty (harder = smaller zone)
	# Make the zone size range more dramatic
	target_zone_size = lerp(0.2, 0.05, difficulty)
	
	# Ensure we have enough space on both sides of the target zone
	var min_position = target_zone_size
	var max_position = 1.0 - target_zone_size
	target_zone_position = clampf(randf_range(min_position, max_position), min_position, max_position)
	
	print("Target zone position (center):", target_zone_position)
	print("Target zone size:", target_zone_size)
	
	# Calculate logical range for hit detection
	var zone_start = target_zone_position - (target_zone_size / 2)
	var zone_end = target_zone_position + (target_zone_size / 2)
	print("Logical zone range:", zone_start, " to ", zone_end)
	
	# Adjust cursor speed based on difficulty (harder = faster)
	# Make the speed range more dramatic too
	cursor_speed = lerp(0.5, 1.8, difficulty)
	
	# Set up progress bar - set to full to show red background
	progress_bar.max_value = 1.0
	progress_bar.value = 1.0
	
	# Get the actual usable width of the progress bar (excluding any padding)
	var usable_width = progress_bar.size.x
	print("Progress bar global rect:", progress_bar.get_global_rect())
	print("Progress bar size:", progress_bar.size)
	
	if usable_width <= 1:
		push_error("Progress bar width is too small! Waiting for another frame...")
		await get_tree().process_frame
		usable_width = progress_bar.size.x
		print("Updated progress bar size:", progress_bar.size)
	
	# Position target zone (green area)
	var zone_width = target_zone_size * usable_width
	target_zone.custom_minimum_size.x = zone_width
	
	# Calculate visual position from center
	var visual_center = target_zone_position * usable_width
	var visual_start = visual_center - (zone_width / 2)
	
	# Clamp the visual position to stay within the progress bar
	visual_start = clamp(visual_start, 0, usable_width - zone_width)
	target_zone.position.x = visual_start
	
	print("Visual zone width:", zone_width)
	print("Visual zone center:", visual_center)
	print("Visual zone start:", target_zone.position.x)
	print("Visual zone end:", target_zone.position.x + zone_width)
	print("Visual zone range:", target_zone.position.x / usable_width, " to ", (target_zone.position.x + zone_width) / usable_width)
	
	# Set cursor initial state
	cursor_position = 0.0
	cursor.custom_minimum_size.x = 4 # Fixed width for cursor
	cursor.position.x = 0 # Start at left edge
	
	is_active = true

func _process(delta: float) -> void:
	if not is_active and shake_time > 0:
		shake_time -= delta
		if shake_time <= 0:
			# Reset position when shake is done
			panel_container.position = original_container_position
		else:
			# Calculate horizontal shake using sine wave
			var shake_progress = shake_time / SHAKE_DURATION
			var shake_strength = shake_progress * SHAKE_MAGNITUDE
			var shake_offset = sin(shake_progress * SHAKE_FREQUENCY) * shake_strength
			panel_container.position.x = original_container_position.x + shake_offset
	
	if not is_active:
		return
	
	# Move cursor back and forth
	cursor_position += direction * cursor_speed * delta
	
	# Reverse direction at edges
	if cursor_position >= 1.0:
		direction = -1
		cursor_position = 1.0
	elif cursor_position <= 0.0:
		direction = 1
		cursor_position = 0.0
	
	# Update cursor visual position
	var usable_width = progress_bar.size.x
	var visual_cursor_center = cursor_position * usable_width
	var cursor_visual_start = visual_cursor_center - (cursor.custom_minimum_size.x / 2)
	cursor_visual_start = clamp(cursor_visual_start, 0, usable_width - cursor.custom_minimum_size.x)
	cursor.position.x = cursor_visual_start

func _input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("Interact"):
		_check_result()

func _check_result() -> void:
	is_active = false
	
	var usable_width = progress_bar.size.x
	print("\nChecking result:")
	print("Progress bar width:", usable_width)
	print("Cursor position:", cursor_position)
	
	# Get the target zone range with a small margin of error
	var margin = target_zone_size * 0.1 # 10% margin on each side
	var visual_zone_start = (target_zone.position.x / usable_width) - margin
	var visual_zone_end = ((target_zone.position.x + target_zone.custom_minimum_size.x) / usable_width) + margin
	
	print("\nZone range:")
	print("Zone start:", visual_zone_start)
	print("Zone end:", visual_zone_end)
	print("Current position:", cursor_position)
	
	# Check if cursor is within the target zone (with margin)
	var success = cursor_position >= visual_zone_start and cursor_position <= visual_zone_end
	
	if success:
		print("Success! Cursor is in target zone")
		success_particles.position = cursor.position
		success_particles.emitting = true
		await get_tree().create_timer(SUCCESS_DISPLAY_TIME).timeout
	else:
		print("Failure! Cursor is outside target zone")
		print("Distance to start:", cursor_position - visual_zone_start)
		print("Distance to end:", visual_zone_end - cursor_position)
		shake_time = SHAKE_DURATION
		await get_tree().create_timer(RESULT_DISPLAY_TIME).timeout
	
	# Calculate score based on distance to center
	var score = 1.0
	if success:
		var visual_zone_center = visual_zone_start + (visual_zone_end - visual_zone_start) / 2
		var distance_from_center = abs(cursor_position - visual_zone_center)
		var max_distance = (target_zone_size / 2) + margin
		score = 1.0 - (distance_from_center / max_distance)
		score = clamp(score, 0.5, 1.0) # Even barely making it gives 0.5 score
	
	end_minigame(success, score)
