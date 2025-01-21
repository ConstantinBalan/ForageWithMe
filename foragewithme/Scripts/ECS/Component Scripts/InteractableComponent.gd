extends Node

# This is a marker component to identify interactable objects
# The actual interaction logic is handled by the InteractionSystem

@onready var floating_prompt = $FloatingPromptComponent

func _ready():
	add_to_group("interactable")
	print("InteractableComponent initialized")
