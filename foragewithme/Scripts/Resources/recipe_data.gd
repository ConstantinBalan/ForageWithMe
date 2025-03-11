@tool
class_name RecipeData
extends Resource

@export var name: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""

# Recipe requirements
@export var ingredients: Dictionary = {} # item_id: amount
@export var required_tool: String = ""
@export var crafting_time: float = 1.0

# Recipe output
@export var result_item: String = ""
@export var result_amount: int = 1

# Recipe category and difficulty
@export_enum("Food", "Tool", "Crafting Material") var category: String = "Food"
@export_range(1, 5) var difficulty: int = 1

# Visual feedback
@export var crafting_effect: PackedScene # Optional particle effect or animation
@export var success_sound: AudioStream
@export var fail_sound: AudioStream
