extends Weapon

# Export variables allow you to set these in the editor
@export var bullet_speed : float = 100.0
@export var fire_rate : float = 0.25

@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var bullet_spawn_marker: Marker3D = $Marker3D
@export var shoot_sfx: AudioStreamPlayer3D

var can_shoot: bool = true

func _process(delta)->void:
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		shoot()

func shoot()->void:
	attack_signal.emit()
	shoot_sfx.play()
	var bullet: Node3D = bullet.instantiate()
	
	#add child to character out of rotational root detached from any player transform
	BulletContainer.add_child(bullet)

	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = bullet_spawn_marker.global_transform.origin

	# Apply velocity to the bullet
	var direction = global_transform.basis.z.normalized()
	bullet.linear_velocity = direction * bullet_speed

	# Implement fire rate
	can_shoot = false
	fire_rate_timer.start(fire_rate)

func _on_fire_rate_timer_timeout():
	can_shoot = true
