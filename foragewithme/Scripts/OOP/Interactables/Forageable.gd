extends GameObject
class_name Forageable

signal foraged(item)

@export var forageable_data: ForageableItem
@export var respawn_time: float = 300.0  # 5 minutes in seconds

var is_available: bool = true
var time_since_foraged: float = 0.0

func _ready():
	super._ready()
	add_to_group("forageables")
	if forageable_data:
		# Set up mesh and collision from resource
		var mesh_instance = $MeshInstance3D
		if mesh_instance and forageable_data.mesh:
			mesh_instance.mesh = forageable_data.mesh
			mesh_instance.scale = forageable_data.scale
		
		var collision_shape = $CollisionShape3D
		if collision_shape and forageable_data.collision_shape:
			collision_shape.shape = forageable_data.collision_shape

func _process(delta: float) -> void:
	if not is_available:
		time_since_foraged += delta
		if time_since_foraged >= respawn_time:
			respawn()

func interact_with(interactor: Node3D) -> void:
	if not is_available or not interactor is Player or not forageable_data:
		return
		
	forage(interactor as Player)

func forage(player: Player) -> void:
	if player.add_item(forageable_data.name):
		is_available = false
		time_since_foraged = 0.0
		emit_signal("foraged", forageable_data)
		# Hide or change model to show item was foraged
		visible = false

func respawn() -> void:
	is_available = true
	visible = true
	time_since_foraged = 0.0
