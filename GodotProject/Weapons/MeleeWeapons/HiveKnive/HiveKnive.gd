extends Weapon

@onready var hitbox = $HitboxArea
@onready var attack_timer = $AttackTimer
@onready var parry_timer = $ParryTimer

func attack():
	hitbox.monitoring = true
	attack_timer.start()
	pass

func _on_attack_timer_timeout():
	hitbox.monitoring = false


func _on_hitbox_area_body_entered(body):
	print("hit")
