extends Node

func apply_movement(character_body, direction, speed):
	character_body.velocity.x = direction.x * speed
	character_body.velocity.z = direction.z * speed

func apply_gravity(character_body, delta):
	if not character_body.is_on_floor():
		character_body.velocity += character_body.get_gravity() * delta

func apply_jump(character_body, jump_velocity):
	if character_body.is_on_floor():
		character_body.velocity.y = jump_velocity
