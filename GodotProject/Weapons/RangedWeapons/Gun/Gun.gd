extends Weapon
class_name Gun

@onready var mesh_instance : MeshInstance3D = $WeaponMesh
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var bullet_spawn_marker: Marker3D = $BulletSpawn

var can_shoot: bool = true


func _ready() -> void:
	#super._ready()
	mesh_instance.mesh = mesh

func _process(delta)->void:
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		attack()

func attack() -> void:
	if current_ammo <= 0:
		print("not enough ammo for %s" % _name)
		#TODO play empty sound
		return
	
	attack_signal.emit()
	current_ammo -= 1
	
	attack_sfx.play()
	var bullet = bullet.instantiate()
	
	var bullet_damage = Damage.new()
	bullet_damage.initialize(get_owner_ref(), get_damage(), self)
	bullet.damage = bullet_damage
	
	bullet_spawn_marker.add_child(bullet)
	bullet.global_transform.origin = bullet_spawn_marker.global_transform.origin
	#bullet.spawn_pos = bullet.global_position
	var direction = bullet_spawn_marker.global_transform.basis.z.normalized()
	bullet.look_at(bullet.global_transform.origin + direction, Vector3.UP)
	
	bullet.linear_velocity = direction * _bullet_speed
#
	## fire rate
	can_shoot = false
	fire_rate_timer.start(_fire_rate)


func _on_fire_rate_timer_timeout():
	can_shoot = true
