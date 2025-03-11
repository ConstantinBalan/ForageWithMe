@tool
class_name ForageableItem
extends Resource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
@export var mesh: Mesh # For 3D representation
@export var collected_mesh: Mesh # Optional mesh for collected state
@export var collision_shape: Shape3D # For physical collision
@export var scale: Vector3 = Vector3.ONE # Scale of the physical object
@export var has_collision: bool = false # Whether the player can walk through this forageable
