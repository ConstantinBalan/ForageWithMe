extends GameObject
class_name Forageable

signal foraged(item)

@export var forageable_data: ForageableItem
@export var respawn_time: float = 300.0  # 5 minutes in seconds

var is_available: bool = true
var time_since_foraged: float = 0.0
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready():
	super._ready()
	add_to_group("forageables")
	
	# Set up collision layers based on forageable_data
	collision_layer = 2  # Layer 2 for raycast interaction
	if forageable_data and forageable_data.has_collision:
		collision_layer |= 1  # Add layer 1 for physical collision
		collision_mask = 1  # Collide with player and other physical objects
	else:
		collision_mask = 0  # Don't collide with anything physically
	
	if forageable_data:
		setup_mesh()
		setup_collision()

func setup_mesh() -> void:
	# Create or get existing mesh instance
	mesh_instance = get_node_or_null("MeshInstance3D")
	if !mesh_instance:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
	
	if forageable_data.mesh:
		mesh_instance.mesh = forageable_data.mesh
		mesh_instance.scale = forageable_data.scale

func setup_collision() -> void:
	# Create or get existing collision shape
	collision_shape = get_node_or_null("CollisionShape3D")
	if !collision_shape:
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)
	
	if forageable_data.collision_shape:
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
		if mesh_instance:
			mesh_instance.visible = false

func respawn() -> void:
	is_available = true
	if mesh_instance:
		mesh_instance.visible = true
	time_since_foraged = 0.0
