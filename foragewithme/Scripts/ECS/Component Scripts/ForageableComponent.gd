extends Node

@export var forageable_item: ForageableItem
@export var quantity_available: int = 5
@export var respawn_time: float = 5.0
var last_foraged_time: float = 0.0

# Optional: Reference to the mesh instance that should be hidden when depleted
@export var mesh_instance: Node3D

func _ready():
	add_to_group("forageable_component")
	if forageable_item:
		print("ForageableComponent initialized with item: ", forageable_item.name, " (Quantity: ", quantity_available, ")")
	
	# If no mesh instance is set, try to find it in parent
	if !mesh_instance and owner is Node3D:
		mesh_instance = owner.get_node_or_null("MeshInstance3D")
