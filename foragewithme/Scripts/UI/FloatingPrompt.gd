class_name FloatingPrompt
extends Node3D

var target: Node3D
var offset: Vector3 = Vector3(0, 2, 0)
var is_visible: bool = false

@onready var label_3d = $Label3D
@onready var animation_player = $AnimationPlayer


func _ready():
	# Instead of hide(), set initial alpha to 0
	label_3d.modulate.a = 0

func _process(_delta):
	if is_visible and is_instance_valid(target):
		global_position = target.global_position + offset
		# Make prompt face camera
		var camera = get_viewport().get_camera_3d()
		if camera:
			look_at(camera.global_position, Vector3.UP)
			rotate_y(PI) # Flip to face camera correctly

func show_prompt(text: String, target_node: Node3D, duration: float = 2.0) -> void:
	target = target_node
	label_3d.text = text
	is_visible = true

	# Don't call show() since we're using modulate alpha
	animation_player.play("floating_prompt_animations/fade_in")

	if duration > 0:
		await get_tree().create_timer(duration).timeout
		hide_prompt()

func hide_prompt() -> void:
	animation_player.play("floating_prompt_animations/fade_out")
	await animation_player.animation_finished
	is_visible = false
