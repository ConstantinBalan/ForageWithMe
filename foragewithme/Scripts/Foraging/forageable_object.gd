@tool
extends StaticBody3D

@export var item_resource: ForageableItem:
	set(value):
		item_resource = value
		_update_mesh()

@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D

func _ready():
	_update_mesh()

func _update_mesh():
	if !is_node_ready():
		await ready

	if item_resource:
		if mesh_instance and item_resource.mesh:
			mesh_instance.mesh = item_resource.mesh
			mesh_instance.scale = item_resource.scale

		if collision_shape and item_resource.collision_shape:
			collision_shape.shape = item_resource.collision_shape
			collision_shape.scale = item_resource.scale

func collect():
	var inventory_system = get_tree().get_first_node_in_group("inventory_system")
	if inventory_system:
		inventory_system.add_item(item_resource)
		queue_free() # Remove from world after collecting
