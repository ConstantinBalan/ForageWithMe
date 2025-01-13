extends Control

@onready var prompt_label = $PromptLabel

func show_prompt(text: String):
	prompt_label.text = text
	show()

func hide_prompt():
	hide()
