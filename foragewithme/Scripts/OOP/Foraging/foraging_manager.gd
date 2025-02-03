extends Node
class_name ForagingManager

const MINIGAME_SCENES = {
	"timing": preload("res://Scenes/Minigames/timing_minigame.tscn"),
	"pattern": preload("res://Scenes/Minigames/pattern_minigame.tscn"),
	"qte": preload("res://Scenes/Minigames/qte_minigame.tscn")
}

# Map item types to their preferred mini-game types and proficiency categories
const ITEM_CONFIGS = {
	"Wild Berries": {"minigame": "timing", "category": "berries"},
	"Mushrooms": {"minigame": "pattern", "category": "mushrooms"},
	"Oak Log": {"minigame": "qte", "category": "wood"}
}

signal foraging_completed(success: bool, item_data: Dictionary)

var current_minigame: ForagingMinigameBase
var active_item: Dictionary

# The tutorial manager will be set by the autoload system
@onready var tutorial_manager = get_node("/root/MiniGameTutorialManager") if has_node("/root/MiniGameTutorialManager") else null

func _ready() -> void:
	if tutorial_manager:
		tutorial_manager.connect("tutorial_completed", _on_tutorial_completed)

func get_ui_layer() -> Node:
	return get_node("/root/Game/UI")

func start_foraging(item_data: Dictionary) -> void:
	var ui = get_ui_layer()
	if not ui:
		push_error("No UI layer found in GameManager!")
		return
		
	active_item = item_data
	print(active_item)
	# Get item configuration
	var item_config = ITEM_CONFIGS.get(item_data.name, {"minigame": "timing", "category": "general"})
	var minigame_type = item_config.minigame
	
	# Check if tutorial is needed and tutorial manager exists
	if tutorial_manager and not tutorial_manager.is_tutorial_completed(minigame_type + "_minigame"):
		tutorial_manager.show_tutorial(minigame_type + "_minigame", self)
		# Wait for tutorial completion before starting minigame
		await tutorial_manager.tutorial_completed
	
	# Start minigame only once, after tutorial if needed
	_start_minigame(item_config)

func _start_minigame(item_config: Dictionary) -> void:
	var ui = get_ui_layer()
	if not ui:
		push_error("No UI layer found in GameManager!")
		return
		
	var minigame_type = item_config.minigame
	var proficiency_category = item_config.category
	
	# Get current proficiency
	var player_proficiency = PlayerDataManager.get_foraging_proficiency(proficiency_category)
	
	# Create appropriate minigame instance
	var minigame_scene = MINIGAME_SCENES[minigame_type]
	var minigame_instance = minigame_scene.instantiate()
	ui.add_child(minigame_instance)
	current_minigame = minigame_instance
	
	# Initialize and connect signals
	current_minigame.initialize(active_item, player_proficiency)
	current_minigame.connect("minigame_completed", _on_minigame_completed.bind(proficiency_category))
	
	# Start the minigame
	print("ForagingManager starting minigame")
	current_minigame.start_minigame()

func try_skip_minigame() -> bool:
	if current_minigame and current_minigame.player_proficiency >= 0.8:
		current_minigame.skip_minigame()
		return true
	return false

func _on_tutorial_completed(_tutorial_id: String) -> void:
	# Remove this since we now start the minigame after tutorial in start_foraging
	pass

func _on_minigame_completed(success: bool, score: float, proficiency_category: String) -> void:
	# Store item data before cleanup
	var item_data = active_item.duplicate()
	
	# Update player proficiency
	PlayerDataManager.update_foraging_proficiency(proficiency_category, score if success else -0.1)
	
	# Emit signal with the stored item data
	emit_signal("foraging_completed", success, item_data)
	
	# Clean up
	if current_minigame:
		current_minigame.queue_free()
	current_minigame = null
	active_item = {}
