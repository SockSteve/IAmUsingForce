class_name TestDummy
extends Enemy

@export var behaviour: Node3D # Node responsible for enemy movement.

func _ready() -> void:
	animation_player.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		animation_player.play("idle")


# Function to handle death.
func die() -> void:
	print("die")
