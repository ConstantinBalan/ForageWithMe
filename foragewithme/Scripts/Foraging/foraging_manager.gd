extends Node
class_name ForagingManager

# Map item types to their proficiency categories
const ITEM_CONFIGS = {
	"Wild Berries": {"category": "berries"},
	"Mushrooms": {"category": "mushrooms"},
	"Oak Log": {"category": "wood"}
}

signal foraging_completed(success: bool, item_data: Dictionary)

var active_item: Dictionary

func _ready() -> void:
	pass

func get_ui_layer() -> Node:
	return get_node("/root/Game/UI")

func start_foraging(item_data: Dictionary) -> void:
	active_item = item_data
	print("Foraging started for: ", active_item.name)
	
	# Get item configuration
	var item_config = ITEM_CONFIGS.get(item_data.name, {"category": "general"})
	var proficiency_category = item_config.category
	
	# Get current proficiency
	var player_proficiency = PlayerDataManager.get_foraging_proficiency(proficiency_category)
	
	# Always succeed but with varying quality based on proficiency
	var success = true
	var quality = randf_range(0.5, 1.0) + (player_proficiency * 0.5)
	quality = clamp(quality, 0.0, 1.0)
	
	# Update player proficiency
	PlayerDataManager.update_foraging_proficiency(proficiency_category, quality)
	
	# Add a small delay to simulate the foraging action
	await get_tree().create_timer(0.5).timeout
	
	# Emit completion signal
	emit_signal("foraging_completed", success, active_item)
