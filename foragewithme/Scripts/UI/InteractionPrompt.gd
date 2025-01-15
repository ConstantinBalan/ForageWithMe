# This script is deprecated - using FloatingPromptComponent instead
extends Control

@onready var prompt_label = $InteractionPrompt
@onready var interaction_system = get_tree().get_first_node_in_group("interaction_system")

func _ready():
	# Hide this UI element since we're using 3D labels now
	hide()
	print("InteractionPrompt UI ready")
	if not prompt_label:
		push_error("Prompt label not found! Make sure you have a Label node named 'InteractionPrompt'")
		return
		
	# Make sure Control is visible but label starts hidden
	prompt_label.hide()
	prompt_label.text = ""

func _process(_delta):
	if not interaction_system or not prompt_label:
		return
		
	var current = interaction_system.current_interactable
	if current and current.has_node("ForageableComponent"):
		var forageable = current.get_node("ForageableComponent")
		if forageable.can_forage():
			if not prompt_label.visible:
				print("Showing prompt for: ", current.name)
				prompt_label.show()
				prompt_label.text = "Press E to forage " + forageable.item_type
		else:
			if prompt_label.visible:
				print("Hiding prompt - cannot forage")
				prompt_label.hide()
	elif current and current.is_in_group("villager"):
		prompt_label.text = "Press E to talk"
		if not prompt_label.visible:
			print("Showing prompt for villager")
			prompt_label.show()
	else:
		if prompt_label.visible:
			print("Hiding prompt - no interactable")
			prompt_label.hide()
