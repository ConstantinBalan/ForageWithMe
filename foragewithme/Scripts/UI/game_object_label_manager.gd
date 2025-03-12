extends Node3D

const FLOATING_PROMPT_SCENE = preload("res://Scenes/UI/FloatingPrompt.tscn")

var active_prompts = {}
var label_offset = Vector3(0, 1.5, 0) # Default offset above objects

func _ready():
	add_to_group("game_object_label_manager")

func show_label(game_object: GameObject, text: String) -> void:
	if not is_instance_valid(game_object) or text.is_empty():
		return

	# If there's already a prompt for this object, update its text
	if active_prompts.has(game_object):
		var prompt = active_prompts[game_object]
		if is_instance_valid(prompt):
			prompt.show_prompt(text, game_object, 0) # Duration 0 means it stays until hidden
		return

	# Create new prompt
	var prompt = FLOATING_PROMPT_SCENE.instantiate()
	add_child(prompt)
	prompt.offset = label_offset
	prompt.show_prompt(text, game_object, 0) # Duration 0 means it stays until hidden
	active_prompts[game_object] = prompt

func hide_label(game_object: GameObject) -> void:
	if active_prompts.has(game_object):
		var prompt = active_prompts[game_object]
		if is_instance_valid(prompt):
			prompt.hide_prompt()
			await prompt.animation_player.animation_finished
			prompt.queue_free()
		active_prompts.erase(game_object)

func hide_all_labels() -> void:
	for game_object in active_prompts.keys():
		hide_label(game_object)

# Optional: Adjust label offset for specific object types
func set_label_offset(offset: Vector3) -> void:
	label_offset = offset
