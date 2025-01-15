extends Node

# This is a marker component to identify interactable objects
# The actual interaction logic is handled by the InteractionSystem

@onready var floating_prompt = $FloatingPromptComponent

func _ready():
	print("InteractableComponent initialized")
	add_to_group("interactable")
	
	if not floating_prompt:
		push_error("InteractableComponent: FloatingPromptComponent not found!")
		
func show_interaction_prompt(text: String):
	if floating_prompt:
		floating_prompt.show_prompt(text)
		
func hide_interaction_prompt():
	if floating_prompt:
		floating_prompt.hide_prompt()
