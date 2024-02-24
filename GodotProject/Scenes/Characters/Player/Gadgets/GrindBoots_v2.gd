extends Node3D

var id = "g00"

@onready var player: Player = find_parent("Player")
@onready var shape_cast_ground: ShapeCast3D = $ShapeCast3D
@onready var shape_cast_left: ShapeCast3D = $ShapeCast3DLeft
@onready var shape_cast_right: ShapeCast3D = $ShapeCast3DRight

var canGrind: bool = true
var grinding: bool = false 
var current_grindrail
var nearby_grindrails_info

#at the start, we minimize the results array that contains the
#intersection point data from the shape_cast_ground3D
#and we add the player to the exception list
func _ready():
	shape_cast_ground.add_exception(player)
	shape_cast_left.add_exception(player)
	shape_cast_right.add_exception(player)

#here we implemented the logic for when a grindrail was detected and the player
#should start grinding
# note that the movement logic lives in the player intern state machine
func _physics_process(delta):
	if shape_cast_ground.is_colliding():
		if shape_cast_ground.get_collider(0).is_in_group("grindRail") and canGrind:
			current_grindrail = shape_cast_ground.get_collider(0).get_parent()
			canGrind = false
			grinding = true
			shape_cast_left.set_enabled(true)
			shape_cast_right.set_enabled(true)
			

#this function gets called by the state machine
func end_grind():
	grinding = false
	$GrindEndCooldown.start()
	shape_cast_left.set_enabled(false)
	shape_cast_right.set_enabled(false)

#this timer exists so the player doesn't immediately start to grind again after
#getting off the grindrail
func _on_grind_end_cooldown_timeout():
	canGrind = true
