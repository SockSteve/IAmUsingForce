extends Camera3D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		position.y += 1
		
	if Input.is_action_pressed("move_down"):
		position.y -= 1
		
	if Input.is_action_pressed("move_left"):
		position.x += 1
		
	if Input.is_action_pressed("move_right"):
		position.x -= 1
		
	if Input.is_action_pressed("ui_up"):
		rotation.y += 1 * delta
		
	if Input.is_action_pressed("ui_down"):
		rotation.y -= 1 * delta
		
	if Input.is_action_pressed("ui_left"):
		rotation.x += 1 * delta
		
	if Input.is_action_pressed("ui_right"):
		rotation.x -= 1 * delta
