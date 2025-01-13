# Attach this to a GPUParticles3D node
var particle_material = ParticleProcessMaterial.new()
particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
particle_material.emission_box_extents = Vector3(2, 0.1, 2)  # Emit from a flat area
particle_material.direction = Vector3(0, 1, 0)  # Float upward
particle_material.spread = 45.0  # Add some randomness
particle_material.gravity = Vector3(0, -0.1, 0)  # Very slight downward pull
particle_material.initial_velocity_min = 0.1
particle_material.initial_velocity_max = 0.3
