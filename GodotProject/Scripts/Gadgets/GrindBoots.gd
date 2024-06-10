"""
In this class we set up the the logic for initializing and handling the Grind state.
The grinding logic is housed in the state machine.
"""
extends Gadget

@onready var player: Player = find_parent("Player") #works because this gadget is always in tree upon collecting
#shapecast for detecting grindrails
@onready var shape_cast_ground: ShapeCast3D = $ShapeCast3D
@onready var shape_cast_left: ShapeCast3D = $ShapeCast3DLeft
@onready var shape_cast_right: ShapeCast3D = $ShapeCast3DRight

#current grindrail
var current_grindrail : Path3D = null

#grainding variables
@export var grind_jump_curve: Curve = load("res://Scripts/Gadgets/GrindJumpCurve.tres")
@export var grindrail_change_jump_curve: Curve = load("res://Scripts/Gadgets/GrindJumpCurve.tres")
@export var grind_curve_time_factor: float = 1
@export var grind_speed_time_factor: float = .3

var initialize_grinding: bool = true

#debug
var exc_arr_l: Array = []
var exc_arr_r: Array = []

#we probe for grindrails with a shapecast
func _physics_process(delta):
	#we test if we collide with a grindrail
	if shape_cast_ground.is_colliding():
		#if we collide with a grindrail and can grind, we set the parameters for the Grinding state
		if shape_cast_ground.get_collider(0).is_in_group("grindRail") and player.can_grind:
			if initialize_grinding:
				
				current_grindrail = shape_cast_ground.get_collider(0).get_parent()
				player.can_grind = false
				player.is_grinding = true
				shape_cast_left.add_exception_rid(shape_cast_ground.get_collider_rid(0))
				shape_cast_right.add_exception_rid(shape_cast_ground.get_collider_rid(0))
				exc_arr_l.append(shape_cast_ground.get_collider_rid(0))
				exc_arr_r.append(shape_cast_ground.get_collider_rid(0))
				#here we setup the shapecast for left and right to probe for grindrails where i can jump to
				shape_cast_left.set_enabled(true)
				shape_cast_right.set_enabled(true)
				initialize_grinding = false
			
			shape_cast_left.force_shapecast_update()
			shape_cast_right.force_shapecast_update()

#this function is used for changing the grindrails
#this function gets called by the state machine
func get_side_rail_path3d(direction: StringName) -> Path3D:
	shape_cast_left.force_shapecast_update()
	shape_cast_right.force_shapecast_update()
	if direction == "left":
		if shape_cast_left.is_colliding():
			return shape_cast_left.get_collider(0).get_parent()
	
	if direction == "right":
		if shape_cast_right.is_colliding():
			return shape_cast_right.get_collider(0).get_parent()
	
	return null

func change_current_grindrail_to(direction: StringName) -> Path3D:
	clear_grindrail_exceptions()
	shape_cast_left.force_shapecast_update()
	shape_cast_right.force_shapecast_update()
	if direction == "left":
		if shape_cast_left.is_colliding():
			shape_cast_left.add_exception_rid(shape_cast_left.get_collider_rid(0))
			shape_cast_right.add_exception_rid(shape_cast_left.get_collider_rid(0))
			exc_arr_l.append(shape_cast_ground.get_collider_rid(0))
			exc_arr_r.append(shape_cast_ground.get_collider_rid(0))
			current_grindrail = shape_cast_left.get_collider(0).get_parent()
			return shape_cast_left.get_collider(0).get_parent()
	
	if direction == "right":
		if shape_cast_right.is_colliding():
			shape_cast_left.add_exception_rid(shape_cast_right.get_collider_rid(0))
			shape_cast_right.add_exception_rid(shape_cast_right.get_collider_rid(0))
			exc_arr_l.append(shape_cast_ground.get_collider_rid(0))
			exc_arr_r.append(shape_cast_ground.get_collider_rid(0))
			current_grindrail = shape_cast_right.get_collider(0).get_parent()
			return shape_cast_right.get_collider(0).get_parent()
	return null


func clear_grindrail_exceptions():
	shape_cast_left.clear_exceptions()
	exc_arr_l = []
	shape_cast_right.clear_exceptions()
	exc_arr_r = []

#this function is for cleaning up the grind state. We also won't allow the player to grind
#for a short time so the player can be released from the grindrail
#this function gets called by the state machine
func end_grind():
	initialize_grinding = true
	clear_grindrail_exceptions()
	current_grindrail = null
	player.is_grinding = false
	$GrindEndCooldown.start()
	shape_cast_left.set_enabled(false)
	shape_cast_right.set_enabled(false)

#this timer exists so the player doesn't immediately start to grind again after
#getting off the grindrail
func _on_grind_end_cooldown_timeout():
	player.can_grind = true
