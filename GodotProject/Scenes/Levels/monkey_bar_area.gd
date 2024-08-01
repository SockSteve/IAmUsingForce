extends Area3D




func _on_body_entered(body):
	if body.is_in_group("player"):
		body.is_monkey_bar = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.is_monkey_bar = false
