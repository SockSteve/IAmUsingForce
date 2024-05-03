extends CharacterBody3D

var time: float = 0
var bullet = preload("res://Scenes/Characters/Enemies/StationaryTurret/TestEnemyBullet_1.tscn")
@export var bullet_speed : float = 10.0

func _physics_process(delta):
	time = time + delta
	if time >=3:
		shoot()
		time=0
	
func shoot():
	var bullet = bullet.instantiate()
	#add child to character out of rotational root detached from any player transform
	get_parent().add_child(bullet)

	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = $Marker3D.global_transform.origin

	# Apply velocity to the bullet
	var direction = transform.basis.z.normalized()
	bullet.linear_velocity = direction * bullet_speed
