extends Node

# Store references to your level scenes
var level_scenes = {
   # "forest": preload("res://levels/forest_level.tscn"),
   # "cave": preload("res://levels/cave_level.tscn"),
   # "mountain": preload("res://levels/mountain_level.tscn")
}

# Keep track of the current level node
var current_level = null

func _ready():
	pass
	# Get reference to your SubViewport
	#var viewport = $CanvasLayer/SubViewportContainer/SubViewport
	
	# Load the initial level
	#change_level("forest", viewport)

func change_level(level_name: String, viewport: SubViewport):
	# First, let's clean up the current level if it exists
	if current_level:
		current_level.queue_free()
		
	# Create the new level instance
	var new_level = level_scenes[level_name].instantiate()
	
	# Add it to the SubViewport
	viewport.add_child(new_level)
	current_level = new_level
	
	# You might want to trigger any level-specific initialization here
	# For example, setting up the player's starting position
	if new_level.has_method("initialize"):
		new_level.initialize()
