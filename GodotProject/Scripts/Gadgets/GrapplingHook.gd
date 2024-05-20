#"""
#This class manages the activation and the end of the grapple state.
#The actual grapple logic is implemented in the state machine
#"""

extends Node3D

var grapple_points : Array = []
var nearest_grapple_point

var joint
var direction_normal_to_origin: Vector3 = Vector3.ZERO
var player = null #gets initialized as soon as the first grapple point is detected

#physics_process is disabled because there lives our logic for doing pull/swing/tug
func _ready():
	set_physics_process(false)

#we have the gadget and want to use it
func _input(event):
	print("echo")
	if Input.is_action_just_pressed("interact"):
		activate()


#here we test if any grappling points are in reach
#and if any grappling points are there, we set the player state bool and put it in the players hand
func activate():
	
	if grapple_points.is_empty(): #or player == null:
		return
	
	if player == null:
		return
	
	elif grapple_points.size() == 1:
		nearest_grapple_point = grapple_points.front()
	
	else:
		nearest_grapple_point = grapple_points.front()
		for grapple_point in grapple_points:
			if self.global_position.distance_to(nearest_grapple_point.global_position) > self.global_position.distance_to(grapple_point.global_position):
				nearest_grapple_point = grapple_point
	
	
	player.is_grappling = true
	player.put_in_hand(self)
	initialize_grappling_mode()
	set_physics_process(true)
	$Rope.visible = true
	update_rope_transform(nearest_grapple_point.global_position)

#physics_process is only used for the rope here
func _physics_process(delta):
	if nearest_grapple_point != null:
		update_rope_transform(nearest_grapple_point.global_transform.origin)

func end_grapple():
	
	player.is_grappling = false
	set_physics_process(false)
	$Rope.visible = false
	nearest_grapple_point = null

func update_rope_transform(grapple_point_position: Vector3) -> void:
	var rope = $Rope # Adjust the path
	var gadget_pos = global_transform.origin
	var direction = grapple_point_position - gadget_pos
	var distance = direction.length()
	
	$Rope.global_position = gadget_pos + direction / 2.0
	direction = direction.normalized()
	direction_normal_to_origin = direction
	rope.scale = Vector3(rope.scale.x, rope.scale.y, distance)
	rope.look_at_from_position($Rope.global_position, grapple_point_position, Vector3.UP)


#called by the grapple points
#when player is in reach of a grapple point, it adds itself to the array grapple_points
func add_grapple_point(grapple_point):
	grapple_points.append(grapple_point)

#called by the grapple points
#when player is out of reach of a grapple point, it removes itself to the array grapple_points
func remove_grapple_point(grapple_point):
	grapple_points.erase(grapple_point)

#when the grappling hook successfully activates this function is called
#it is responsible for assigning the player to the grapple joint
func initialize_grappling_mode():
	match nearest_grapple_point.grapple_point_type:
		
		nearest_grapple_point.grapple_point_type_enum.PULL:
			joint = nearest_grapple_point.get_joint()
			nearest_grapple_point.add_child(joint)
			joint.node_b = player._physics_body.get_path()
			
		nearest_grapple_point.grapple_point_type_enum.SWING:
			joint = nearest_grapple_point.get_joint()
			joint.node_b = player._physics_body.get_path()
			
		nearest_grapple_point.grapple_point_type_enum.TUG:
			joint = nearest_grapple_point.get_joint()
			push_warning("Tog: TODO")
