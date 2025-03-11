### ResourceLoader.gd
# Singleton responsible for loading, caching, and providing access to game resources
#
# Called by:
# - GameManager.gd (initialization)
# - QuestManager.gd (for quest resources)
# - DialogueSystem.gd (for dialogue resources)
# - ForagingManager.gd (for forageable items)
# - Any script that needs access to resources
#
# No direct signals emitted
###
extends Node

# Resource paths
const FORAGEABLE_PATH = "res://Resources/Forageables/"
const VILLAGER_PATH = "res://Resources/Villagers/"
const RECIPE_PATH = "res://Resources/Recipes/"
const DIALOGUE_PATH = "res://Resources/Dialogues/"
const QUEST_PATH = "res://Resources/Quests/"

# Cached resources
var forageables: Dictionary = {}
var villagers: Dictionary = {}
var recipes: Dictionary = {}
var dialogues: Dictionary = {}
var quests: Dictionary = {}

### _ready
# Called when the node enters the scene tree
# Initializes by loading all resources from their respective directories
###
func _ready():
	load_all_resources()

### load_all_resources
# Loads all game resources from their respective directories
# Calls specialized loading functions for each resource type
###
func load_all_resources() -> void:
	load_resources_in_directory(FORAGEABLE_PATH, forageables, ForageableItem)
	load_resources_in_directory(VILLAGER_PATH, villagers, VillagerData)
	load_resources_in_directory(RECIPE_PATH, recipes, RecipeData)
	load_resources_in_directory(DIALOGUE_PATH, dialogues, DialogueData)
	load_resources_in_directory(QUEST_PATH, quests, QuestData)

	print("ResourceLoader: Loaded %d forageables" % forageables.size())
	print("ResourceLoader: Loaded %d villagers" % villagers.size())
	print("ResourceLoader: Loaded %d recipes" % recipes.size())
	print("ResourceLoader: Loaded %d dialogues" % dialogues.size())
	print("ResourceLoader: Loaded %d quests" % quests.size())

### load_resources_in_directory
# Generic function to load resources of a specific type from a directory
#
# Parameters:
# - path: Directory path to load from
# - cache: Dictionary to store loaded resources in
# - resource_type: The type of resource to validate against
###
# gdlint: disable=unused-argument
func load_resources_in_directory(path: String, cache: Dictionary, resource_type) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource = load(path.path_join(file_name))
				if resource and (resource is resource_type):
					var id = file_name.get_basename()
					cache[id] = resource
			file_name = dir.get_next()
	else:
		print("ResourceLoader: Could not open directory: " + path)

### get_forageable
# Retrieves a forageable item resource by ID
#
# Parameters:
# - id: String identifier for the forageable
#
# Returns:
# - ForageableItem resource or null if not found
###
func get_forageable(id: String) -> ForageableItem:
	return forageables.get(id)

### get_villager
# Retrieves a villager data resource by ID
#
# Parameters:
# - id: String identifier for the villager
#
# Returns:
# - VillagerData resource or null if not found
###
func get_villager(id: String) -> VillagerData:
	return villagers.get(id)

### get_recipe
# Retrieves a recipe data resource by ID
#
# Parameters:
# - id: String identifier for the recipe
#
# Returns:
# - RecipeData resource or null if not found
###
func get_recipe(id: String) -> RecipeData:
	return recipes.get(id)

### get_dialogue
# Retrieves a dialogue data resource by ID
#
# Parameters:
# - id: String identifier for the dialogue
#
# Returns:
# - DialogueData resource or null if not found
###
func get_dialogue(id: String) -> DialogueData:
	return dialogues.get(id)

### get_quest
# Retrieves a quest data resource by ID
#
# Parameters:
# - id: String identifier for the quest
#
# Returns:
# - QuestData resource or null if not found
###
func get_quest(id: String) -> QuestData:
	return quests.get(id)

### get_all_forageables
# Retrieves all forageable item resources
#
# Returns:
# - Array of all ForageableItem resources
###
func get_all_forageables() -> Array:
	return forageables.values()

### get_all_villagers
# Retrieves all villager data resources
#
# Returns:
# - Array of all VillagerData resources
###
func get_all_villagers() -> Array:
	return villagers.values()

### get_all_recipes
# Retrieves all recipe data resources
#
# Returns:
# - Array of all RecipeData resources
###
func get_all_recipes() -> Array:
	return recipes.values()

### get_all_quests
# Retrieves all quest data resources
#
# Returns:
# - Array of all QuestData resources
###
func get_all_quests() -> Array:
	return quests.values()

### get_dialogues_for_villager
# Retrieves all dialogue resources for a specific villager
#
# Parameters:
# - villager_id: String identifier for the villager
#
# Returns:
# - Array of DialogueData resources for the villager
###
func get_dialogues_for_villager(villager_id: String) -> Array:
	var villager_dialogues = []
	for dialogue in dialogues.values():
		if dialogue.speaker == villager_id:
			villager_dialogues.append(dialogue)
	return villager_dialogues

### get_forageables_for_area_and_season
# Retrieves forageables that can be found in a specific area and season
#
# Parameters:
# - area_type: String identifier for the area type (e.g., "forest", "mountain")
# - season: String identifier for the season (e.g., "Spring", "Summer")
#
# Returns:
# - Array of ForageableItem resources available in that area and season
###
func get_forageables_for_area_and_season(area_type: String, season: String) -> Array:
	var result = []
	for forageable in forageables.values():
		if forageable.areas.has(area_type) and forageable.seasons.has(season):
			result.append(forageable)
	return result

### get_random_forageable
# Retrieves a random forageable item resource
#
# Returns:
# - A random ForageableItem resource or null if none exist
###
func get_random_forageable() -> ForageableItem:
	if forageables.is_empty():
		return null
	var keys = forageables.keys()
	return forageables[keys[randi() % keys.size()]]

### get_recipes_by_category
# Retrieves recipes filtered by category
#
# Parameters:
# - category: String category name (e.g., "cooking", "crafting")
#
# Returns:
# - Array of RecipeData resources in that category
###
func get_recipes_by_category(category: String) -> Array:
	var filtered = []
	for recipe in recipes.values():
		if recipe.category == category:
			filtered.append(recipe)
	return filtered

### get_recipes_by_difficulty
# Retrieves recipes filtered by difficulty level
#
# Parameters:
# - difficulty: Integer difficulty level
#
# Returns:
# - Array of RecipeData resources with matching difficulty
###
func get_recipes_by_difficulty(difficulty: int) -> Array:
	var filtered = []
	for recipe in recipes.values():
		if recipe.difficulty == difficulty:
			filtered.append(recipe)
	return filtered

### get_recipes_by_ingredient
# Retrieves recipes that require a specific ingredient
#
# Parameters:
# - ingredient_id: String identifier for the ingredient
#
# Returns:
# - Array of RecipeData resources that use the ingredient
###
func get_recipes_by_ingredient(ingredient_id: String) -> Array:
	var filtered = []
	for recipe in recipes.values():
		for ingredient in recipe.ingredients:
			if ingredient.id == ingredient_id:
				filtered.append(recipe)
				break
	return filtered

### get_quests_by_type
# Retrieves quests filtered by quest type
#
# Parameters:
# - quest_type: String quest type (e.g., "gathering", "delivery")
#
# Returns:
# - Array of QuestData resources of that type
###
func get_quests_by_type(quest_type: String) -> Array:
	var filtered = []
	for quest in quests.values():
		if quest.type == quest_type:
			filtered.append(quest)
	return filtered
