extends Node

class_name GameResourceLoader

# Resource paths
const FORAGEABLE_PATH = "res://Resources/Forageables/"
const VILLAGER_PATH = "res://Resources/Villagers/"
const RECIPE_PATH = "res://Resources/Recipes/"
const DIALOGUE_PATH = "res://Resources/Dialogues/"

# Cached resources
var forageables: Dictionary = {}
var villagers: Dictionary = {}
var recipes: Dictionary = {}
var dialogues: Dictionary = {}

func _ready():
	load_all_resources()

func load_all_resources() -> void:
	load_resources_in_directory(FORAGEABLE_PATH, forageables, ForageableItem)
	load_resources_in_directory(VILLAGER_PATH, villagers, VillagerData)
	load_resources_in_directory(RECIPE_PATH, recipes, RecipeData)
	load_resources_in_directory(DIALOGUE_PATH, dialogues, DialogueData)

func load_resources_in_directory(path: String, cache: Dictionary, resource_type: Resource) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource = load(path.path_join(file_name))
				if resource.get_class() == resource_type.get_class():
					var id = file_name.get_basename()
					cache[id] = resource
			file_name = dir.get_next()

# Getter functions
func get_forageable(id: String) -> ForageableItem:
	return forageables.get(id)

func get_villager(id: String) -> VillagerData:
	return villagers.get(id)

func get_recipe(id: String) -> RecipeData:
	return recipes.get(id)

func get_dialogue(id: String) -> DialogueData:
	return dialogues.get(id)

# Get all resources of a type
func get_all_forageables() -> Array[ForageableItem]:
	return forageables.values()

func get_all_villagers() -> Array[VillagerData]:
	return villagers.values()

func get_all_recipes() -> Array[RecipeData]:
	return recipes.values()

func get_dialogues_for_villager(villager_id: String) -> Array[DialogueData]:
	var villager_dialogues: Array[DialogueData] = []
	for dialogue in dialogues.values():
		if dialogue.speaker == villager_id:
			villager_dialogues.append(dialogue)
	return villager_dialogues

# Helper functions
func get_random_forageable() -> ForageableItem:
	if forageables.is_empty():
		return null
	return forageables.values().pick_random()

func get_recipes_by_category(category: String) -> Array[RecipeData]:
	var filtered: Array[RecipeData] = []
	for recipe in recipes.values():
		if recipe.category == category:
			filtered.append(recipe)
	return filtered

func get_recipes_by_difficulty(difficulty: int) -> Array[RecipeData]:
	var filtered: Array[RecipeData] = []
	for recipe in recipes.values():
		if recipe.difficulty == difficulty:
			filtered.append(recipe)
	return filtered
