extends Weapon

@onready var mesh_instance : MeshInstance3D = $WeaponMesh
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var bullet_spawn_marker: Marker3D = $BulletSpawn

var can_shoot: bool = true

func set_weapon_stats(new_weapon_stats: WeaponStats):
	weapon_stats = new_weapon_stats


func _ready() -> void:
	mesh_instance.mesh = weapon_stats.mesh


func _process(delta)->void:
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		attack()


func attack() -> void:
	if weapon_stats.current_ammo <= 0:
		print("not enough ammo for %s" % weapon_stats.name)
		#TODO play empty sound
		return
	
	attack_signal.emit()
	weapon_stats.current_ammo -= 1
	
	attack_sfx.play()
	var bullet = bullet.instantiate()
	bullet._owner = self
	
	bullet_spawn_marker.add_child(bullet)
	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = bullet_spawn_marker.global_transform.origin
	bullet.rotation = get_parent().get_parent().get_parent().rotation
	
	## Apply velocity to the bullet
	var direction = bullet_spawn_marker.global_transform.basis.z.normalized()
	print(direction)
	bullet.linear_velocity = direction * _bullet_speed
#
	## Implement fire rate
	can_shoot = false
	fire_rate_timer.start(_fire_rate)


func _on_fire_rate_timer_timeout():
	can_shoot = true
