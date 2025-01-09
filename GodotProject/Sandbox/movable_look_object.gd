extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var initial_position = global_position
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@export var circle_around: bool = false
var timer = 0

func _physics_process(delta: float) -> void:
	if circle_around:
		path_follow_3d.progress_ratio += delta * .5
		return
		
	position += ray_cast_3d.target_position * 10 * delta
	
	timer += delta
	
	if timer >= 2:
		timer = 0
		global_position = initial_position
	
