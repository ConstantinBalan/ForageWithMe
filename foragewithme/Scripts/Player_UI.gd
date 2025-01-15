extends CanvasLayer

@onready var inventory_panel = $Panels/InventoryPanel
@onready var dialogue_panel = $Panels/DialoguePanel
@onready var interaction_prompt = $Prompts/InteractionPrompt
@onready var relationship_display = $HUD/RelationshipDisplay
@onready var tool_bar = $HUD/ToolBar

# Track UI states
var active_panel = null
var ui_stack = []  # For managing multiple UI elements

# Called when the node enters the scene tree for the first time.
func _ready():
	for panel in $Panels.get_children():
		panel.hide()
	for prompt in $InteractionPromptUI.get_children():
		prompt.hide()
#		inventory_panel.closed.connect(on_panel_closed)
#		dialogue_panel.closed.connect(on_panel_closed)


func show_panel(panel_name: String):
	var panel = get_node("Panels/" + panel_name)
	if panel:
		if active_panel:
			active_panel.hide()
		panel.show()
		active_panel = panel

func on_panel_closed():
	active_panel = null
