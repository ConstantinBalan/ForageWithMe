extends Node3D
class_name FloatingPrompt

@onready var label_3d = $Label3D
@onready var animation_player = $AnimationPlayer

var target: Node3D
var offset: Vector3 = Vector3(0, 2, 0)
var is_visible: bool = false

func _ready():
	hide()

func _process(_delta):
	if is_visible and is_instance_valid(target):
		global_position = target.global_position + offset
		# Make prompt face camera
		var camera = get_viewport().get_camera_3d()
		if camera:
			look_at(camera.global_position, Vector3.UP)
			rotate_y(PI)  # Flip to face camera correctly

func show_prompt(text: String, target_node: Node3D, duration: float = 2.0) -> void:
	target = target_node
	label_3d.text = text
	is_visible = true
	show()
	
	if duration > 0:
		animation_player.play("fade_in")
		await get_tree().create_timer(duration).timeout
		hide_prompt()

func hide_prompt() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	is_visible = false
	hide()
