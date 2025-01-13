extends CharacterBody3D

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
