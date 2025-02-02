class_name EnemyBase
extends CharacterBody3D

signal died(xp: int, gold: int) # Signal to notify XP and gold on death.
signal apply_damage(damage: Damage) # Signal for applying damage.

@export var behaviour: Node3D # Node responsible for enemy movement.
@export var health: int = 99999 # Default health value.
@export var xp_reward: int = 50 # XP given upon death.
@export var gold_reward: int = 10 # Gold given upon death.

@onready var animation_player: AnimationPlayer = $Skin/AnimationPlayer
@onready var attraction_point: Marker3D = %AttractionPoint
@onready var ch_36: Material = $Skin/GeneralSkeleton/Ch36.get_active_material(0)
@onready var skin = $Skin/GeneralSkeleton/Ch36
func _ready() -> void:
	var material = skin.get_active_material(0).duplicate()
	skin.set_surface_override_material(0, material)
	set_physics_process(false)
	animation_player.play("idle")
	apply_damage.connect(take_damage)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		animation_player.play("idle")

func take_damage(damage: Damage) -> void:
	animation_player.play("hit")
	#ch_36.set_instance_shader_parameter()
	#var next_pass_material = ch_36.next_pass
	#next_pass_material.set_shader_parameter("shock_color", Vector3(1, 0, 0))  # Optional
	#next_pass_material.set_shader_parameter("TIME", 0.0)  # Reset TIME to trigger the flash
	#next_pass_material.set_shader_parameter("trigger_flash", true)
	#await get_tree().create_timer(0.6).timeout
	#next_pass_material.set_shader_parameter("trigger_flash", false)
	flash()
	health -= damage.value
	if health <= 0:
		die(damage)
	else:
		animation_player.play("hit")

# Function to handle death.
func die(damage_source: Damage) -> void:
	print(damage_source)
	damage_source.source.gain_xp.emit(xp_reward)
	damage_source.instigator.get_inventory().add_money(gold_reward)
	#emit_signal(xp_reward, gold_reward)
	queue_free() # Remove this enemy from the scene.


#@onready var ch_36: Material = $Skin/GeneralSkeleton/Ch36.get_active_material(0)
var tween: Tween
func flash():
	#var original_color = ch_36.albedo_color
	#ch_36.albedo_color = Color(1, 0, 0)  # Set to red
	#await get_tree().create_timer(.2).timeout
	#ch_36.albedo_color = original_color  # Reset to original color
	var next_pass_material: ShaderMaterial = skin.get_surface_override_material(0).next_pass
	#var next_pass_material: ShaderMaterial = ch_36.next_pass
	next_pass_material.set_shader_parameter("flash_time", 0.0)
	if tween:
		tween.kill()
	tween = create_tween()
	print(next_pass_material.get_shader_parameter("flash_time"))
	tween.tween_property(next_pass_material, "shader_parameter/flash_time", 1.0, 1.0)
