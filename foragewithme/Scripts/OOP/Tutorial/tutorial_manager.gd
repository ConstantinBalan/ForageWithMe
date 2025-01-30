extends Node
class_name TutorialManager

signal tutorial_completed(tutorial_id: String)

const TUTORIAL_DATA = {
	"timing_minigame": {
		"title": "Timing Challenge",
		"steps": [
			"Stop the cursor in the green zone to collect items.",
			"The faster and more accurate you are, the better your reward!",
			"As you improve, the target zone will get smaller but rewards increase."
		]
	},
	"pattern_minigame": {
		"title": "Pattern Memory",
		"steps": [
			"Watch the pattern of arrows carefully.",
			"Repeat the pattern using the arrow keys.",
			"Complete the pattern before time runs out!"
		]
	},
	"qte_minigame": {
		"title": "Quick Actions",
		"steps": [
			"Press the shown key quickly when it appears.",
			"Chain multiple successful presses for better rewards.",
			"Don't press the wrong key or you'll fail!"
		]
	}
}

var completed_tutorials: Dictionary = {}
var current_tutorial: MinigameTutorial

func _ready() -> void:
	# Load completed tutorials from PlayerDataManager when the autoload initializes
	completed_tutorials = PlayerDataManager.get_completed_tutorials()

func show_tutorial(tutorial_id: String, parent_node: Node) -> void:
	if completed_tutorials.get(tutorial_id, false):
		return
		
	# Clean up any existing tutorial
	if current_tutorial and is_instance_valid(current_tutorial):
		current_tutorial.queue_free()
		
	var tutorial_scene = load("res://Scenes/Tutorial/minigame_tutorial.tscn")
	var tutorial = tutorial_scene.instantiate()
	parent_node.add_child(tutorial)
	current_tutorial = tutorial
	
	tutorial.initialize(TUTORIAL_DATA[tutorial_id])
	tutorial.connect("tutorial_completed", _on_tutorial_completed.bind(tutorial_id))

func _on_tutorial_completed(tutorial_id: String) -> void:
	completed_tutorials[tutorial_id] = true
	PlayerDataManager.save_tutorial_completion(tutorial_id)
	emit_signal("tutorial_completed", tutorial_id)
	
	if current_tutorial:
		current_tutorial.queue_free()
		current_tutorial = null

func is_tutorial_completed(tutorial_id: String) -> bool:
	return completed_tutorials.get(tutorial_id, false)

# Optional: Force show a tutorial even if completed (for testing or player request)
func force_show_tutorial(tutorial_id: String, parent_node: Node) -> void:
	var tutorial_scene = load("res://Scenes/Tutorial/minigame_tutorial.tscn")
	var tutorial = tutorial_scene.instantiate()
	parent_node.add_child(tutorial)
	current_tutorial = tutorial
	
	tutorial.initialize(TUTORIAL_DATA[tutorial_id])
	tutorial.connect("tutorial_completed", func(): current_tutorial.queue_free())
