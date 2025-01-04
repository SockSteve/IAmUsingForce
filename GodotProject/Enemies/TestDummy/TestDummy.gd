class_name EnemyBase
extends CharacterBody3D

signal died(xp: int, gold: int) # Signal to notify XP and gold on death.
signal apply_damage(damage: Damage) # Signal for applying damage.

@export var behaviour: Node3D # Node responsible for enemy movement.
@export var health: int = 99999 # Default health value.
@export var xp_reward: int = 50 # XP given upon death.
@export var gold_reward: int = 10 # Gold given upon death.

@onready var animation_player: AnimationPlayer = $Skin/AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	apply_damage.connect(take_damage)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		animation_player.play("idle")

func take_damage(damage: Damage) -> void:
	animation_player.play("hit")
	
	health -= damage.value
	if health <= 0:
		die(damage.source)
	else:
		animation_player.play("hit")

# Function to handle death.
func die(damage_source: Weapon) -> void:
	print(damage_source)
	damage_source.gain_xp.emit(xp_reward)
	#emit_signal(xp_reward, gold_reward)
	queue_free() # Remove this enemy from the scene.
