extends ForagingMinigameBase
class_name PatternMinigame

@onready var pattern_container = $PatternContainer
@onready var input_container = $InputContainer
@onready var timer_bar = $TimerBar

const DIRECTIONS = ["up", "down", "left", "right"]
var pattern: Array[String] = []
var player_input: Array[String] = []
var pattern_length: int
var time_per_input: float = 1.0
var remaining_time: float

func _setup_minigame() -> void:
	# Pattern length based on difficulty (3-6 inputs)
	pattern_length = int(lerp(3, 6, difficulty))
	time_per_input = lerp(1.2, 0.8, difficulty)
	
	# Generate random pattern
	for i in pattern_length:
		pattern.append(DIRECTIONS[randi() % DIRECTIONS.size()])
	
	# Display pattern
	_show_pattern()

func _show_pattern() -> void:
	var tween = create_tween()
	for direction in pattern:
		var arrow = _create_arrow(direction)
		pattern_container.add_child(arrow)
		# Animate arrow
		tween.tween_property(arrow, "modulate:a", 1.0, 0.3)
		tween.tween_interval(0.5)
		tween.tween_property(arrow, "modulate:a", 0.3, 0.3)
	
	tween.tween_callback(_start_input_phase)

func _start_input_phase() -> void:
	remaining_time = time_per_input * pattern_length
	timer_bar.max_value = remaining_time
	timer_bar.value = remaining_time

func _process(delta: float) -> void:
	if remaining_time > 0:
		remaining_time -= delta
		timer_bar.value = remaining_time
		if remaining_time <= 0:
			_check_result()

func _input(event: InputEvent) -> void:
	if remaining_time <= 0:
		return
		
	var direction = ""
	if event.is_action_pressed("move_up"): direction = "up"
	elif event.is_action_pressed("move_down"): direction = "down"
	elif event.is_action_pressed("move_left"): direction = "left"
	elif event.is_action_pressed("move_right"): direction = "right"
	
	if direction != "":
		player_input.append(direction)
		var arrow = _create_arrow(direction)
		input_container.add_child(arrow)
		
		if player_input.size() >= pattern_length:
			_check_result()

func _check_result() -> void:
	var correct_inputs = 0
	for i in pattern.size():
		if i < player_input.size() and pattern[i] == player_input[i]:
			correct_inputs += 1
	
	var success = correct_inputs == pattern.size()
	var score = float(correct_inputs) / pattern.size()
	
	end_minigame(success, score)

func _create_arrow(direction: String) -> TextureRect:
	var arrow = TextureRect.new()
	# You'll need to create arrow textures and load them here
	arrow.texture = load("res://Images/arrow_" + direction + ".png")
	arrow.modulate.a = 0.3
	arrow.custom_minimum_size = Vector2(32, 32)
	return arrow
