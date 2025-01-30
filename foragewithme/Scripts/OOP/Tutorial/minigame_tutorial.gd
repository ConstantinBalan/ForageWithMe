extends Control
class_name MinigameTutorial

signal tutorial_completed

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var step_label = $Panel/VBoxContainer/StepLabel
@onready var next_button = $Panel/VBoxContainer/NextButton
@onready var animation_player = $AnimationPlayer

var tutorial_data: Dictionary
var current_step: int = 0
var steps: Array

func _ready() -> void:
	next_button.connect("pressed", _on_next_pressed)
	
	# Create fade in animation
	var fade_in = Animation.new()
	var track_idx = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_idx, ":modulate")
	fade_in.track_insert_key(track_idx, 0.0, Color(1, 1, 1, 0))
	fade_in.track_insert_key(track_idx, 0.3, Color(1, 1, 1, 1))
	animation_player.add_animation("fade_in", fade_in)
	
	# Create fade out animation
	var fade_out = Animation.new()
	track_idx = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_idx, ":modulate")
	fade_out.track_insert_key(track_idx, 0.0, Color(1, 1, 1, 1))
	fade_out.track_insert_key(track_idx, 0.3, Color(1, 1, 1, 0))
	animation_player.add_animation("fade_out", fade_out)

func initialize(data: Dictionary) -> void:
	tutorial_data = data
	title_label.text = data.title
	steps = data.steps
	show_step(0)
	animation_player.play("fade_in")

func show_step(step: int) -> void:
	current_step = step
	step_label.text = steps[step]
	
	if current_step == steps.size() - 1:
		next_button.text = "Got it!"
	else:
		next_button.text = "Next"
		
	# Animate step text
	var tween = create_tween()
	step_label.modulate.a = 0
	tween.tween_property(step_label, "modulate:a", 1.0, 0.3)

func _on_next_pressed() -> void:
	if current_step < steps.size() - 1:
		show_step(current_step + 1)
	else:
		# Play fade out animation and emit completion signal
		animation_player.play("fade_out")
		await animation_player.animation_finished
		emit_signal("tutorial_completed")
