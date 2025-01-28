extends Weapon

# Export variables allow you to set these in the editor
@export var bullet_speed : float = 100.0
@export var fire_rate : float = 0.25
@onready var fire_rate_timer: Timer = $FireRateTimer

var can_shoot = true
func _ready() -> void:
	super._ready()

func _process(delta):
	if can_shoot and Input.is_action_pressed("ranged_attack"):
		attack()

func attack():
	if weapon_stats.current_ammo <= 0:
		print("not enough ammo for %s" % weapon_stats.name)
		#TODO play empty sound
		return
	
	attack_signal.emit()
	weapon_stats.current_ammo -= 1
	
	attack_sfx.play()
	var bullet = bullet.instantiate()
	bullet._owner = self
	bullet_spawn.add_child(bullet)
	bullet.global_transform.origin = bullet_spawn.global_transform.origin
	bullet.spawn_pos = bullet.global_position
	var direction = bullet_spawn.global_transform.basis.z.normalized()
	bullet.look_at(bullet.global_transform.origin + direction, Vector3.UP)
	bullet.linear_velocity = direction * _bullet_speed
#
	## fire rate
	can_shoot = false
	fire_rate_timer.start(fire_rate)


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true
