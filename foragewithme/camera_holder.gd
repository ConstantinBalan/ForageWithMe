extends Node3D

func _input(event):
	if event is InputEventMouseMotion:
		rotate_z(deg_to_rad(event.relative.y * -0.04))
