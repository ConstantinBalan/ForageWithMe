extends Node3D

var total_rotation = 0.0  # Track total rotation

func _input(event):
	if event is InputEventMouseMotion:
		# Define rotation limits in radians
		var z_low = deg_to_rad(-50)
		var z_high = deg_to_rad(70)
		
		# Calculate the proposed new rotation
		var rotation_amount = deg_to_rad(event.relative.y * -0.04)
		var new_total = total_rotation + rotation_amount
		
		# Clamp the total rotation
		var clamped_total = clamp(new_total, z_low, z_high)
		
		# Only rotate by the difference
		var actual_rotation = clamped_total - total_rotation
		rotate_z(actual_rotation)
		
		# Update our total rotation
		total_rotation = clamped_total
