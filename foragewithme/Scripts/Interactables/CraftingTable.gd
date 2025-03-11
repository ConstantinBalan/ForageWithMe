class_name CraftingTable
extends GameObject

signal crafting_started(recipe)
signal crafting_completed(recipe)

@export var available_recipes: Array[RecipeData] = []
var is_in_use: bool = false
var current_recipe: RecipeData

func _ready():
	super._ready()
	add_to_group("crafting_tables")

func interact_with(interactor: Node3D) -> void:
	if not interactor is Player or is_in_use:
		return

	var player = interactor as Player
	open_crafting_menu(player)

func open_crafting_menu(player: Player) -> void:
	# Implementation would connect to UI system
	var craftable_recipes = get_available_recipes(player)
	# Show crafting UI with craftable_recipes

func get_available_recipes(player: Player) -> Array[RecipeData]:
	var craftable = []
	for recipe in available_recipes:
		if can_craft_recipe(recipe, player):
			craftable.append(recipe)
	return craftable

func can_craft_recipe(recipe: RecipeData, player: Player) -> bool:
	if not recipe:
		return false

	# Check if player has required tool
	if recipe.required_tool and not player.has_tool(recipe.required_tool):
		return false

	# Check if player has all ingredients
	for ingredient in recipe.ingredients:
		var required_amount = recipe.ingredients[ingredient]
		if not player.has_item(ingredient, required_amount):
			return false
	return true

func start_crafting(recipe: RecipeData, player: Player) -> bool:
	if not can_craft_recipe(recipe, player):
		return false

	# Remove ingredients from player inventory
	for ingredient in recipe.ingredients:
		var amount = recipe.ingredients[ingredient]
		player.remove_item(ingredient, amount)

	is_in_use = true
	current_recipe = recipe
	emit_signal("crafting_started", recipe)

	# Play crafting effects if available
	if recipe.crafting_effect:
		var effect = recipe.crafting_effect.instantiate()
		add_child(effect)

	if recipe.success_sound:
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = recipe.success_sound
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(func(): audio_player.queue_free())

	# Start crafting timer
	var timer = get_tree().create_timer(recipe.crafting_time)
	timer.timeout.connect(_on_crafting_completed.bind(player))
	return true

func _on_crafting_completed(player: Player) -> void:
	if not is_in_use or not current_recipe:
		return

	player.add_item(current_recipe.result_item, current_recipe.result_amount)
	emit_signal("crafting_completed", current_recipe)

	is_in_use = false
	current_recipe = null
