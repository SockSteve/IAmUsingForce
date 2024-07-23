extends PlayerState


func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	player._character_skin.set_moving(false)

func physics_update(delta: float) -> void:
	player.velocity.y = Vector3.UP.y
