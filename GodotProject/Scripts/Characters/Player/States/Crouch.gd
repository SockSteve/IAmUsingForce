extends PlayerState
func enter(_msg := {}) -> void:
	pass

func physics_update(delta: float) -> void:
	player._character_skin.crouch()
	pass
