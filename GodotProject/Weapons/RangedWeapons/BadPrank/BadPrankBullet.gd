extends Node3D

var linear_velocity = Vector3.ZERO

func _ready():
	# Set the bullet to deactivate after a few seconds to prevent it from traveling indefinitely
	#set_process(false)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta):
	# Move the bullet
	translate(linear_velocity * delta)
