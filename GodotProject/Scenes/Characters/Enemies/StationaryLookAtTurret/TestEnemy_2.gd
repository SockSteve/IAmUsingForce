extends CharacterBody3D

@export var rotation_speed: float = 10.0
@export var shooting_interval: float = 2.0


var time: float = 0
var bullet_scene = preload("res://Scenes/Characters/Enemies/StationaryLookAtTurret/TestEnemyBullet_2.tscn")

@export var bullet_speed : float = 10.0
var player_detected: bool = false
var player: Node = null

func _process(delta):
	if player_detected: 
		#look_at(player.global_position + Vector3(0,1,0))
		# Rotate turret towards player
		look_at_target(delta)
	
	time = time + delta
	if time >=3:
		#shoot()
		# Handle shooting mechanism
		if player_detected: 
			handle_shooting(delta)
		time=0

#func _physics_process(delta):
	#
	#if player_detected: 
		##look_at(player.global_position + Vector3(0,1,0))
		## Rotate turret towards player
		#look_at_target(delta)
	#
	#time = time + delta
	#if time >=3:
		##shoot()
		## Handle shooting mechanism
		#if player_detected: 
			#handle_shooting(delta)
		#time=0

# Export variables for customization in the editor

var time_since_last_shot: float = 0.0

#func _process(delta):
	## Rotate turret towards player
	#look_at_target(delta)
	## Handle shooting mechanism
	#handle_shooting(delta)

func look_at_target(delta):
	var player_position = player.global_transform.origin
	var direction = (player_position - global_transform.origin).normalized()
	var current_direction = global_transform.basis.z.normalized()
	
	var angle_to_player = acos(current_direction.dot(direction))
	if angle_to_player > rotation_speed * delta:
		var rotation_axis = current_direction.cross(direction).normalized()
		global_transform.basis = global_transform.basis.rotated(rotation_axis, rotation_speed * delta).orthonormalized()

func handle_shooting(delta):
	shoot_bullet()

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	#bullet.global_transform.origin = global_transform.origin
	bullet.global_transform.origin = global_transform.origin + global_transform.basis.z.normalized() * 1
	#var target_direction: Vector3 = (player.global_position - bullet.position).normalized()
	#target_direction.angle_to(player.position)
	var target_direction: Vector3 = bullet.position.direction_to(player.position)
	#bullet.look_at(player.global_position + Vector3(0,1,0), Vector3.UP)
	bullet.linear_velocity = target_direction * bullet_speed

func _on_collision_shape_3d_2_body_entered(body):
	if body.is_in_group('player'):
		player_detected = true
		player = body


func _on_collision_shape_3d_2_body_exited(body):
	if body.is_in_group('player'):
		player_detected = false
		player = null
