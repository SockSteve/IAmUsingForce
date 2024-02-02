extends Node3D

# Export variables allow you to set these in the editor
@export var bullet_scene : PackedScene
@export var bullet_speed : float = 100.0
@export var fire_rate : float = 0.5

var can_shoot = true

func _ready():
	pass

func _process(delta):
	if can_shoot and Input.is_action_just_pressed("ranged_attack"):
		print("ssss")
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	#get_parent().add_child(bullet)
	self.add_child(bullet)
	print(bullet)

	# Set the bullet's position to the gun's position
	bullet.global_transform = global_transform

	# Apply velocity to the bullet
	var direction = global_transform.basis.z.normalized()
	bullet.linear_velocity = direction * bullet_speed

	# Implement fire rate
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
