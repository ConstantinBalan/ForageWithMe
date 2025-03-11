extends Node

# Signals
signal shader_compilation_completed
signal resource_preload_completed
signal scene_preload_completed
signal all_loading_completed

# Constant paths
const LOADING_SCREEN_PATH = "res://Scenes/UI/loading_screen.tscn"

# Resource lists to preload - customize these as needed
var ui_scenes = [
	"res://Scenes/UI/floating_prompt.tscn",
	"res://Scenes/UI/inventory_ui.tscn",
	"res://Scenes/UI/inventory_slot.tscn",
	"res://Scenes/UI/loading_screen.tscn",
]

var gameplay_scenes = [
	"res://Scenes/Forageables/forageable_object.tscn",
	"res://Scenes/Forageables/berry_bush.tscn",
	"res://Scenes/Zones/forest_area.tscn",
	"res://Scenes/test_forageable.tscn",
]

var character_scenes = [
	"res://Scenes/Characters/player.tscn",
]

var shaders = [
	"res://Assets/Shaders/camera_dither.gdshader",
	"res://Assets/Shaders/forest_area.gdshader",
]

# Runtime references (should come after other variables)
var loading_screen = null
var ui_canvas_layer = null
var _test_shader_compilation = null

# Track loading progress
var total_items_to_load = 0
var items_loaded = 0
var current_operation = ""

# Loading messages (using underscore prefix for "private" variables)
var _quirky_loading_messages = [
    "Gathering acorns...",
    "Herding squirrels...",
    "Chasing fireflies...",
    "Whispering to the trees...",
    "Counting tree rings..."
]

func _ready():
	# Wait one frame to ensure everything is initialized
	await get_tree().process_frame

	# Initialize shader compilation test callable
	_test_shader_compilation = Callable(self, "_on_shader_compiled")

	# Find or create UI canvas layer
	_ensure_ui_canvas_layer()

func _ensure_ui_canvas_layer():
	# First check if a UI canvas layer already exists
	ui_canvas_layer = get_tree().root.get_node_or_null("UICanvasLayer")

	# If not found, create one
	if ui_canvas_layer == null:
		ui_canvas_layer = CanvasLayer.new()
		ui_canvas_layer.name = "UICanvasLayer"
		ui_canvas_layer.layer = 100 # High layer number to be on top
		get_tree().root.call_deferred("add_child", ui_canvas_layer)
		# Wait a frame to ensure the canvas layer is added
		await get_tree().process_frame

func start_game_loading():
	# Calculate total items
	total_items_to_load = (
		ui_scenes.size() + gameplay_scenes.size() + character_scenes.size() + shaders.size() + 4
	) # +4 for resource categories
	items_loaded = 0

	# Make sure we have a UI canvas layer
	await _ensure_ui_canvas_layer()

	# Load the loading screen first
	var loading_scene = load(LOADING_SCREEN_PATH)
	loading_screen = loading_scene.instantiate()
	ui_canvas_layer.call_deferred("add_child", loading_screen)
	# Wait a frame to ensure the loading screen is added
	await get_tree().process_frame

	# Start preloading everything
	_preload_all_resources()

func _preload_all_resources():
	# Start with shader compilation
	current_operation = "Compiling shaders..."
	_update_loading_screen()
	_compile_shaders()
	await shader_compilation_completed

	# Load all resource categories
	current_operation = "Loading game resources..."
	_update_loading_screen()
	_ensure_resources_loaded()
	await resource_preload_completed

	# Load UI scenes
	current_operation = "Loading UI elements..."
	_update_loading_screen()
	_preload_scenes(ui_scenes)

	# Load gameplay scenes
	current_operation = "Loading gameplay elements..."
	_update_loading_screen()
	_preload_scenes(gameplay_scenes)

	# Load character scenes
	current_operation = "Loading characters..."
	_update_loading_screen()
	_preload_scenes(character_scenes)

	# Complete loading
	current_operation = get_random_loading_message()
	_update_loading_screen()
	await get_tree().create_timer(0.3).timeout

	emit_signal("all_loading_completed")
	loading_screen.finish_loading()

func _compile_shaders():
	var compiled_count = 0

	# Start shader compilation for each shader
	for shader_path in shaders:
		var shader = load(shader_path)
		compiled_count += 1
		items_loaded += 1
		_update_loading_screen()
		await get_tree().process_frame

	await get_tree().process_frame
	emit_signal("shader_compilation_completed")

func _ensure_resources_loaded():
	# Make sure GameResourceLoader has loaded all resources
	if has_node("/root/GameResourceLoader"):
		var resource_loader = get_node("/root/GameResourceLoader")

		# If resources aren't loaded yet, do it now
		if resource_loader.forageables.size() == 0:
			resource_loader.load_all_resources()

		# Count major resource categories
		items_loaded += 4 # 4 resource categories
		_update_loading_screen()

	await get_tree().process_frame
	emit_signal("resource_preload_completed")

func _preload_scenes(scene_list):
	for scene_path in scene_list:
		# Load the scene resource but don't instantiate
		var scene = load(scene_path)
		items_loaded += 1
		_update_loading_screen()
		await get_tree().process_frame

	emit_signal("scene_preload_completed")

func _update_loading_screen():
	if loading_screen:
		loading_screen.set_progress(items_loaded, total_items_to_load)
		current_operation = _get_random_loading_message() # Select a new random message
		loading_screen.set_status(current_operation)

# Transition to a new scene with loading screen
func change_scene(target_scene_path):
	# Make sure we have a UI canvas layer
	await _ensure_ui_canvas_layer()

	# Show loading screen first
	var loading_scene = load(LOADING_SCREEN_PATH)
	loading_screen = loading_scene.instantiate()
	ui_canvas_layer.call_deferred("add_child", loading_screen)
	# Wait a frame to ensure the loading screen is added
	await get_tree().process_frame

	loading_screen.start_loading(target_scene_path)

	# Configure loading for transition
	total_items_to_load = 3 # Simplified for scene transitions
	items_loaded = 0

	# Simple transition loading steps
	current_operation = "Unloading current scene..."
	_update_loading_screen()
	await get_tree().process_frame
	items_loaded += 1

	current_operation = "Loading new scene..."
	_update_loading_screen()
	await get_tree().process_frame
	items_loaded += 1

	current_operation = "Preparing environment..."
	_update_loading_screen()
	await get_tree().process_frame
	items_loaded += 1

	# Mark as complete, let the loading screen handle the actual transition
	current_operation = "Ready!"
	_update_loading_screen()

	loading_screen.finish_loading()

func _get_random_loading_message():
	return _quirky_loading_messages[randi() % _quirky_loading_messages.size()]
