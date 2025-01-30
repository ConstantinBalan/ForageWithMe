extends ForagingMinigameBase
class_name TimingMinigame

@onready var progress_bar = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar
@onready var target_zone = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar/TargetZone
@onready var cursor = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar/Cursor

var cursor_speed: float = 100.0 # Percentage per second
var cursor_position: float = 0.0 # 0 to 1
var direction: int = 1
var target_zone_size: float
var target_zone_position: float
var is_active: bool = false

const MARGIN_OF_ERROR: float = 0.05 # 5% extra margin on each side

func _ready() -> void:
	# Wait for layout to be ready
	await get_tree().process_frame
	_setup_minigame()

func _setup_minigame() -> void:
	# Set up target zone based on difficulty (harder = smaller zone)
	target_zone_size = lerp(0.3, 0.1, difficulty)
	target_zone_position = randf_range(target_zone_size, 1.0 - target_zone_size)
	
	print("Target zone position:", target_zone_position)
	print("Target zone size:", target_zone_size)
	print("Target zone range:", target_zone_position - target_zone_size / 2, " to ", target_zone_position + target_zone_size / 2)
	
	# Adjust cursor speed based on difficulty (harder = faster)
	cursor_speed = lerp(0.7, 1.5, difficulty)
	
	# Set up progress bar - set to full to show red background
	progress_bar.max_value = 1.0
	progress_bar.value = 1.0
	
	# Position target zone (green area)
	var zone_width = target_zone_size * progress_bar.size.x
	target_zone.custom_minimum_size.x = zone_width
	target_zone.position.x = target_zone_position * progress_bar.size.x - zone_width / 2
	
	# Set cursor initial state
	cursor_position = 0.0
	cursor.custom_minimum_size.x = 4 # Fixed width for cursor
	
	is_active = true

func _process(delta: float) -> void:
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
	
	# Update cursor position
	cursor.position.x = cursor_position * progress_bar.size.x

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	
	if event.is_action_pressed("Interact"):
		_check_result()

func _check_result() -> void:
	is_active = false
	
	# Calculate target zone range with margin of error
	var zone_start = target_zone_position - (target_zone_size / 2 + MARGIN_OF_ERROR)
	var zone_end = target_zone_position + (target_zone_size / 2 + MARGIN_OF_ERROR)
	
	print("Cursor position:", cursor_position)
	print("Zone range:", zone_start, " to ", zone_end)
	
	# Check if cursor is within target zone (including margin)
	var success = cursor_position >= zone_start and cursor_position <= zone_end
	
	if success:
		print("Success! Cursor is in target zone")
		# Print player inventory for testing
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("get_inventory"):
			print("Player inventory:", player.get_inventory())
	else:
		print("Failure! Cursor is outside target zone")
	
	# Calculate score based on distance to center
	var score = 1.0
	if success:
		var distance_from_center = abs(cursor_position - target_zone_position)
		var max_distance = target_zone_size / 2 + MARGIN_OF_ERROR
		score = 1.0 - (distance_from_center / max_distance)
		score = clamp(score, 0.5, 1.0) # Even barely making it gives 0.5 score
	
	end_minigame(success, score)
