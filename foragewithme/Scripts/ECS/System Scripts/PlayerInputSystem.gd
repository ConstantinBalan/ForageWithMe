extends Node

signal interaction_requested(player)
signal sprint_started
signal sprint_ended
signal jump_requested(player)

var is_sprinting = false

func _ready():
	add_to_group("player_input_system")
	await get_tree().process_frame

func _input(event):
	if not get_tree().has_group("player"):
		return
		
	var player = get_tree().get_nodes_in_group("player")[0]
	
	if event.is_action_pressed("Interact"):
		interaction_requested.emit(player)
	
	if event.is_action_pressed("Sprint"):
		is_sprinting = true
		sprint_started.emit()
	elif event.is_action_released("Sprint"):
		is_sprinting = false
		sprint_ended.emit()
		
	if event.is_action_pressed("Jump"):
		jump_requested.emit(player)
		
	if event is InputEventMouseMotion:
		handle_mouse_motion(player, event)
		
	if event.is_action_pressed("ui_cancel"):
		handle_escape()

func _physics_process(_delta):
	if not get_tree().has_group("player"):
		return
		
	var player = get_tree().get_nodes_in_group("player")[0]
	var movement_system = get_tree().get_nodes_in_group("movement_system")[0]
	if movement_system:
		# Get WASD input
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("Move Right") - Input.get_action_strength("Move Left")
		input_dir.y = Input.get_action_strength("Move Backward") - Input.get_action_strength("Move Forward")
		input_dir = input_dir.normalized()
		
		movement_system.process_movement(player, input_dir, is_sprinting, _delta)

func handle_mouse_motion(player, event):
	var character_body = player.owner
	if character_body:
		character_body.rotate_y(deg_to_rad(event.relative.x * -0.04))

func handle_escape():
	get_tree().quit()
