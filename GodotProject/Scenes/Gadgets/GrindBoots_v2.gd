extends Node3D

var id = "g00"

@onready var player: Player = find_parent("Player")
@onready var shape_cast_ground: ShapeCast3D = $ShapeCast3D
@onready var shape_cast_left: ShapeCast3D = $ShapeCast3DLeft
@onready var shape_cast_right: ShapeCast3D = $ShapeCast3DRight

var canGrind: bool = true
var grinding: bool = false 
var current_grindrail : Path3D = null


#here we implemented the logic for when a grindrail was detected and the player
#should start grinding
#note that the movement logic lives in the player intern state machine
func _physics_process(delta):
	if shape_cast_ground.is_colliding():
		if shape_cast_ground.get_collider(0).is_in_group("grindRail") and canGrind:
			current_grindrail = shape_cast_ground.get_collider(0).get_parent()
			canGrind = false
			grinding = true
			shape_cast_left.set_enabled(true)
			shape_cast_right.set_enabled(true)
			
			shape_cast_left.add_exception_rid(shape_cast_ground.get_collider_rid(0))
			shape_cast_right.add_exception_rid(shape_cast_ground.get_collider_rid(0))

func get_side_rail_path3d(direction) -> Path3D:
	if direction == "left":
		if shape_cast_left.is_colliding():
			return shape_cast_left.get_collider(0).get_parent()
	
	if direction == "right":
		if shape_cast_right.is_colliding():
			return shape_cast_right.get_collider(0).get_parent()
	
	return null

func clear_grindrail_exceptions():
	shape_cast_left.clear_exceptions()
	shape_cast_right.clear_exceptions()

#this function gets called by the state machine
func end_grind():
	clear_grindrail_exceptions()
	current_grindrail = null
	grinding = false
	$GrindEndCooldown.start()
	shape_cast_left.set_enabled(false)
	shape_cast_right.set_enabled(false)

#this timer exists so the player doesn't immediately start to grind again after
#getting off the grindrail
func _on_grind_end_cooldown_timeout():
	canGrind = true
