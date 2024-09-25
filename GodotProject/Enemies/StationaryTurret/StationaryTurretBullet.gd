extends Node3D

var linear_velocity = Vector3.ZERO
@onready var collision_detector: RayCast3D = $RayCast3D
@export var raycast_length: float = .3

func _ready():
	# Set the bullet to deactivate after a few seconds to prevent it from traveling indefinitely
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta):
	# Move the bullet
	if collision_detector.is_colliding():
		queue_free()
	translate(linear_velocity * delta)
	
func rotate_bullet_to_direction(dir):
	collision_detector.target_position =  global_transform.basis * dir * raycast_length

func _on_bullet_area_body_entered(body):
	print(body)
	queue_free()

func move(direction: Vector3, speed: float):
	collision_detector.target_position =  global_transform.basis * direction * raycast_length
	linear_velocity = direction * speed
