extends Weapon

# Export variables allow you to set these in the editor
@export var bullet_speed : float = 100.0
@export var fire_rate : float = 0.25

var can_shoot = true

func _ready():
	pass

func _process(delta):
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		shoot()

func shoot():
	var bullet = bullet.instantiate()
	#add child to character out of rotational root detached from any player transform
	get_parent().get_parent().get_parent().add_child(bullet)
	#get_tree().root.add_child(bullet)
	print(bullet)

	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = global_transform.origin

	# Apply velocity to the bullet
	var direction = global_transform.basis.z.normalized()
	bullet.linear_velocity = direction * bullet_speed

	# Implement fire rate
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
