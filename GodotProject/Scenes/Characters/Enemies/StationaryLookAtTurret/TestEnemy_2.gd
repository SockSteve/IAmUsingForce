extends CharacterBody3D

@export var rotation_speed: float = 10.0
@export var shooting_interval: float = 2.0

var time: float = 0
var bullet_scene = preload("res://Scenes/Characters/Enemies/StationaryLookAtTurret/TestEnemyBullet_2.tscn")

@export var bullet_speed : float = 10.0
var player_detected: bool = false
var player: Node = null

func _physics_process(delta):
	if player_detected: 
		HelperLibrary.smooth_3d_rotate_towards(self, player, rotation_speed, delta)
	
	time = time + delta
	if time >=3:
		if player_detected: 
			shoot_bullet()
		time=0

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = global_transform.origin + global_transform.basis.z.normalized() * 1
	var target_direction: Vector3 = bullet.position.direction_to(player.position)
	target_direction.y = 0
	bullet.linear_velocity = target_direction * bullet_speed

func _on_collision_shape_3d_2_body_entered(body):
	if body.is_in_group('player'):
		player_detected = true
		player = body

func _on_collision_shape_3d_2_body_exited(body):
	if body.is_in_group('player'):
		player_detected = false
		player = null
