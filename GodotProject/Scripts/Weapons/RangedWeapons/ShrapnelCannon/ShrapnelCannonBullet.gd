extends Node3D


var linear_velocity = Vector3.ZERO

func _process(delta):
	# Move the bullet
	translate(linear_velocity * delta)

func shoot():
	$GPUParticles3D.emitting = true


func _on_gpu_particles_3d_finished():
	queue_free()


func _on_area_3d_body_entered(body):
	print(body)
