@tool
extends Resource
class_name ForageableItem

@export var name: String = ""
@export var texture: Texture2D
@export_multiline var description: String = ""
@export var mesh: Mesh  # For 3D representation
@export var collision_shape: Shape3D  # For physical collision
@export var scale: Vector3 = Vector3.ONE  # Scale of the physical object
