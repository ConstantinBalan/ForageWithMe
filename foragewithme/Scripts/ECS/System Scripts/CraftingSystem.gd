extends Node

func can_craft(player_inventory, recipe):
	for ingredient in recipe.ingredients:
		if not player_inventory.has_item(ingredient, recipe.ingredients[ingredient]):
			return false
	return true

func craft(player_inventory, recipe):
	if can_craft(player_inventory, recipe):
		for ingredient in recipe.ingredients:
			player_inventory.remove_item(ingredient, recipe.ingredients[ingredient])
		for output_item in recipe.output:
			player_inventory.add_item(output_item, recipe.output[output_item])
		return true
	return false
