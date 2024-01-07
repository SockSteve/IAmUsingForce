extends PlayerState
func enter(_msg := {}) -> void:
	if _msg.has("do_air_up_attack"):
		pass
	if _msg.has("do_air_down_attack"):
		pass

func physics_update(delta: float) -> void:
	pass
