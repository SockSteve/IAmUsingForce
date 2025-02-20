class_name Enemy extends CharacterBody3D

signal death(xp: int, gold: int) # Signal to notify XP and gold on death.
signal apply_damage(damage: Damage) # Signal for applying damage.

@export var health: int = 99999 # Default health value.
@export var xp_reward: int = 50 # XP given upon death.
@export var gold_reward: int = 10 # Gold given upon death.

@export var animation_player: AnimationPlayer 
@export var attraction_point: Marker3D

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func take_damage(damage: Damage) -> void:
	animation_player.play("hit")
	flash()
	health -= damage.value
	if health <= 0:
		die(damage)
	else:
		animation_player.play("hit")

# Function to handle death.
func die(damage_source: Damage) -> void:
	print(damage_source)
	damage_source.source.add_xp(xp_reward)
	damage_source.instigator.get_inventory().add_money(gold_reward)
	#emit_signal(xp_reward, gold_reward)
	queue_free() # Remove this enemy from the scene.

@export var enemy_active_material_texture: Material
var tween: Tween
func flash():
	enemy_active_material_texture.next_pass.set_shader_parameter("flash_time", 0.0)
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(enemy_active_material_texture.next_pass, "shader_parameter/flash_time", 1.0, 1.0)
