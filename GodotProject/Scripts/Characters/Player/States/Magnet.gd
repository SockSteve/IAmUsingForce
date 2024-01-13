extends PlayerState
func enter(_msg := {}) -> void:
	pass

func physics_update(delta: float) -> void:
	player.get_floor_normal()
