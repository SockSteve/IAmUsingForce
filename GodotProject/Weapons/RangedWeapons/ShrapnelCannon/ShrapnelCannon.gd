## the shrapnel cannon is a shotgun that does max damage on each pellet. 
## it doesn't do extra damage when more than one pellet hits an enemy
extends Weapon
class_name ShrapnelCannon

@export var spread_angle: float = 5.0
@export var pellet_amnt: int = 8

@onready var shoot_sfx: AudioStreamPlayer3D = $ShootSfx

var can_shoot = true
var enemies_hit: Array[EnemyBase] = []
var destroyed_pellet_amnt = 0 : set =equalize_damage

func _process(_delta):
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		shoot()


func shoot():
	for i in range(pellet_amnt):
		var pellet_direction = get_pellet_direction()
		var bullet_inst = bullet.instantiate()
		bullet_inst.target_position = -pellet_direction
		bullet_inst.global_transform.origin = bullet_spawn.global_transform.origin
		bullet_inst.linear_velocity = -pellet_direction * _bullet_speed
		bullet_inst._owner = self
		bullet_spawn.add_child(bullet_inst)
	#add child to character out of rotational root detached from any player transform
	#get_tree().root.add_child(bullet)

	# Set the bullet's position to the gun's position
	#bullet_inst.global_transform.origin = bullet_spawn_marker.global_transform.origin
	#bullet_inst.shoot()
	shoot_sfx.play()
	# Apply velocity to the bullet
	#var direction = global_transform.basis.z.normalized()
	#bullet.linear_velocity = direction * bullet_speed

	# Implement fire rate
	can_shoot = false
	await get_tree().create_timer(_fire_rate).timeout
	can_shoot = true

func get_pellet_direction() -> Vector3:
	var direction = -bullet_spawn.global_transform.basis.z  # Forward direction
	direction = direction.rotated(bullet_spawn.global_transform.basis.x, deg_to_rad(randf_range(-spread_angle, spread_angle)))
	direction = direction.rotated(bullet_spawn.global_transform.basis.y, deg_to_rad(randf_range(-spread_angle, spread_angle)))
	return direction.normalized()

func equalize_damage(pellet):
	if destroyed_pellet_amnt == pellet_amnt:
		enemies_hit.clear()
		destroyed_pellet_amnt = 0
		
