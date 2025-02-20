class_name TestDummy
extends CharacterBody3D

signal died(xp: int, gold: int) # Signal to notify XP and gold on death.
signal apply_damage(damage: Damage) # Signal for applying damage.

@export var behaviour: Node3D # Node responsible for enemy movement.
@export var health: int = 99999 # Default health value.
@export var xp_reward: int = 50 # XP given upon death.
@export var gold_reward: int = 10 # Gold given upon death.

@onready var animation_player: AnimationPlayer = $Skin/AnimationPlayer
@onready var attraction_point: Marker3D = %AttractionPoint

func _ready() -> void:
	animation_player.play("idle")
	apply_damage.connect(take_damage)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		animation_player.play("idle")

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


@onready var ch_36: Material = $Skin/GeneralSkeleton/Ch36.get_active_material(0)
var tween: Tween
func flash():
	ch_36.next_pass.set_shader_parameter("flash_time", 0.0)
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(ch_36.next_pass, "shader_parameter/flash_time", 1.0, 1.0)
