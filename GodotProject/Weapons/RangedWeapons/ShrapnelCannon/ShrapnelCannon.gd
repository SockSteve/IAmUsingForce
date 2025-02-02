extends Weapon
class_name ShrapnelCannon

# Export variables allow you to set these in the editor
@export var bullet_speed : float = 100.0
@export var fire_rate : float = 1

@onready var bullet_spawn_marker: Marker3D = $BulletSpawn
@onready var shoot_sfx: AudioStreamPlayer3D = $ShootSfx
var can_shoot = true

func _process(_delta):
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		shoot()

func shoot():
	var bullet_inst = bullet.instantiate()
	#add child to character out of rotational root detached from any player transform
	get_parent().get_parent().get_parent().add_child(bullet_inst)
	#get_tree().root.add_child(bullet)

	# Set the bullet's position to the gun's position
	bullet_inst.global_transform.origin = bullet_spawn_marker.global_transform.origin
	bullet_inst.shoot()
	shoot_sfx.play()
	# Apply velocity to the bullet
	#var direction = global_transform.basis.z.normalized()
	#bullet.linear_velocity = direction * bullet_speed

	# Implement fire rate
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
