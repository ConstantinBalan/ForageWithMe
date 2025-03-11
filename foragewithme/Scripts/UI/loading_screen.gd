extends Control

signal loading_completed

# Use variables without @onready to avoid nil issues
var progress_bar
var status_label

# Debug mode
var debug = true

# If we're transitioning between scenes
var next_scene_path: String = ""

# Configuration
var min_load_time: float = 0.5 # Minimum seconds to show loading screen

# Keep track of load time
var load_start_time: float = 0
var can_hide: bool = false
var all_resources_loaded: bool = false

func _ready():
	# Initialize node references
	progress_bar = find_child("ProgressBar", true)
	status_label = find_child("StatusLabel", true)

	# Debug output to see what we found
	if debug:
		print("LoadingScreen nodes found:")
		print("- ProgressBar: " + str(progress_bar))
		print("- StatusLabel: " + str(status_label))
		print("Scene tree structure:")
		_print_scene_tree(self)

	# Ensure progress starts at 0
	if progress_bar and progress_bar is ProgressBar:
		progress_bar.value = 0

	set_status("Initializing...")
	load_start_time = Time.get_unix_time_from_system()

func set_progress(value: float, max_value: float = 100.0):
	# Safety check - if progress_bar is nil or wrong type
	if progress_bar == null:
		if debug:
			print("LoadingScreen: ProgressBar is null, attempting to find it")

		# Try to find it again
		progress_bar = find_child("ProgressBar", true)
		if progress_bar == null and debug:
			print("LoadingScreen: Still couldn't find ProgressBar")
			return

	# Check if progress_bar is actually a ProgressBar type
	if progress_bar is ProgressBar:
		progress_bar.value = (value / max_value) * 100.0
		if debug:
			print("Set progress to: " + str((value / max_value) * 100.0) + "%")
	elif progress_bar != null:
		# For debugging
		print("Progress bar is not a ProgressBar control: " + str(progress_bar.get_class()))

func set_status(text: String):
	if status_label == null:
		if debug:
			print("LoadingScreen: StatusLabel is null, attempting to find it")

		# Try to find it again
		status_label = find_child("StatusLabel", true)
		if status_label == null and debug:
			print("LoadingScreen: Still couldn't find StatusLabel")
			return

	if status_label != null:
		status_label.text = text
		if debug:
			print("Set status to: " + text)

func start_loading(scene_path: String = ""):
	# Reset
	progress_bar.value = 0
	can_hide = false
	all_resources_loaded = false

	# Store next scene if transitioning
	next_scene_path = scene_path

	# Show the loading screen
	visible = true

# Helper function to debug the scene tree
func _print_scene_tree(node, indent = 0):
	var indent_str = ""
	for i in range(indent):
		indent_str += "  "

	print(indent_str + node.name + " (" + node.get_class() + ")")

	for child in node.get_children():
		_print_scene_tree(child, indent + 1)

func finish_loading():
	all_resources_loaded = true

	# Make sure minimum display time has passed
	var elapsed = Time.get_unix_time_from_system() - load_start_time
	if elapsed >= min_load_time:
		_on_loading_complete()
	else:
		# Wait for minimum time
		await get_tree().create_timer(min_load_time - elapsed).timeout
		_on_loading_complete()

func _on_loading_complete():
	# If we're transitioning to a new scene
	if next_scene_path != "":
		# Change to the new scene
		get_tree().change_scene_to_file(next_scene_path)
	else:
		# Just hide the loading screen
		visible = false

	emit_signal("loading_completed")
