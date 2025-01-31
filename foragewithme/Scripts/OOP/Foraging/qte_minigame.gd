extends ForagingMinigameBase
class_name QTEMinigame

@onready var prompt_container = $Background/PromptContainer
@onready var success_particles = $Background/SuccessParticles
@onready var progress_bar = $Background/ProgressBar

const BUTTON_PROMPTS = ["E", "F", "Space"]
var current_prompt: String
var total_prompts: int
var completed_prompts: int
var prompt_time: float = 1.0
var remaining_time: float

func _setup_minigame() -> void:
	# Number of successful prompts needed based on difficulty
	total_prompts = int(lerp(3, 6, difficulty))
	prompt_time = lerp(1.2, 0.7, difficulty)
	completed_prompts = 0
	
	_show_next_prompt()

func _show_next_prompt() -> void:
	current_prompt = BUTTON_PROMPTS[randi() % BUTTON_PROMPTS.size()]
	var prompt_label = prompt_container.get_node("PromptLabel")
	
	# Animate prompt appearance
	var tween = create_tween()
	prompt_label.text = current_prompt
	prompt_label.scale = Vector2.ZERO
	tween.tween_property(prompt_label, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	remaining_time = prompt_time

func _process(delta: float) -> void:
	if remaining_time > 0:
		remaining_time -= delta
		progress_bar.value = remaining_time / prompt_time
		
		if remaining_time <= 0:
			_handle_timeout()

func _input(event: InputEvent) -> void:
	if remaining_time <= 0:
		return
	
	var pressed_key = ""
	if event.is_action_pressed("Interact"): pressed_key = "E"
	elif event.is_action_pressed("Secondary_Interact"): pressed_key = "F"
	elif event.is_action_pressed("Jump"): pressed_key = "Space"
	
	if pressed_key != "":
		if pressed_key == current_prompt:
			_handle_success()
		else:
			_handle_failure()

func _handle_success() -> void:
	completed_prompts += 1
	success_particles.emitting = true
	
	if completed_prompts >= total_prompts:
		end_minigame(true, 1.0)
	else:
		_show_next_prompt()

func _handle_failure() -> void:
	var score = float(completed_prompts) / total_prompts
	end_minigame(false, score)

func _handle_timeout() -> void:
	var score = float(completed_prompts) / total_prompts
	end_minigame(false, score)
