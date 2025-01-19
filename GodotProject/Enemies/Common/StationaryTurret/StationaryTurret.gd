extends StaticBody3D


@export var bullet : PackedScene
@export var bullet_speed : float = 10.0
@export var shoot_delay : float =  3.0

@onready var bullet_spawn_point: Marker3D = $BulletSpawnPoint

var elapsed_time_since_last_bullet_fired: float = 0

func _physics_process(delta):
	elapsed_time_since_last_bullet_fired += delta
	if elapsed_time_since_last_bullet_fired >= shoot_delay:
		shoot()
		elapsed_time_since_last_bullet_fired = 0
	
func shoot():
	var bullet = bullet.instantiate()
	BulletContainer.add_child(bullet)
	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = bullet_spawn_point.global_transform.origin
	# Apply velocity to the bullet
	bullet.move(global_transform.basis.z.normalized(), bullet_speed)
	var direction = global_transform.basis.z.normalized()
	#bullet.rotate_bullet_to_direction(direction)
	bullet.linear_velocity = direction * bullet_speed
