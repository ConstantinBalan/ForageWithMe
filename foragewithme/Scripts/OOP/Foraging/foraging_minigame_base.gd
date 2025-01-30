extends Node
class_name ForagingMinigameBase

signal minigame_completed(success: bool, score: float)
signal minigame_started

# Difficulty ranges from 0 (easiest) to 1 (hardest)
var difficulty: float = 0.5
var player_proficiency: float = 0.0
var item_data: Dictionary

func initialize(item: Dictionary, player_prof: float) -> void:
	item_data = item
	player_proficiency = player_prof
	# Adjust difficulty based on player proficiency
	difficulty = max(0.1, 0.5 - (player_proficiency * 0.1))

func start_minigame() -> void:
	emit_signal("minigame_started")
	_setup_minigame()

func _setup_minigame() -> void:
	# Override in child classes to set up specific mini-game logic
	pass

func end_minigame(success: bool, score: float = 0.0) -> void:
	emit_signal("minigame_completed", success, score)
	queue_free()

func skip_minigame() -> void:
	# Auto-succeed if player proficiency is high enough
	if player_proficiency >= 0.8:
		end_minigame(true, 1.0)
	else:
		# Random success chance based on proficiency
		var success = randf() < (0.5 + player_proficiency * 0.3)
		end_minigame(success, 0.5)
