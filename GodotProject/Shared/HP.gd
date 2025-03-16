extends Node
class_name Hp

signal hp_chaged
signal death

@export var max_health : int = 100
var current_health : int = max_health : set = set_current_health
@export var skin : MeshInstance3D
@export var hit_sfx : AudioStreamPlayer3D
@export var death_sfx : AudioStreamPlayer3D

func set_current_health(new_health: int):
	current_health = new_health
	

func take_damage(damage: Damage) -> void:
	print(damage)
	if skin: flash_red()

	current_health -= damage.value
	clampi(current_health, 0, max_health)
	
	if current_health <= 0:
		if death_sfx: death_sfx.play()
		hp_chaged.emit(damage.source, true)
		death.emit()
		return
	
	hp_chaged.emit(damage.source)
	if hit_sfx: hit_sfx.play()

var tween: Tween
func flash_red():
	skin.material_overlay.set_shader_parameter("flash_time", 0.0)
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(skin.material_overlay, "shader_parameter/flash_time", 1.0, 1.0)
