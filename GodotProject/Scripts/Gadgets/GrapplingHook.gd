extends Node3D

var id = "g01"

var grapple_points : Array = []
var nearest_grapple_point

var grappling: bool = false
var joint
var direction_normal_to_origin: Vector3 = Vector3.ZERO

func _ready():
	set_physics_process(false)

func activate():
	if grapple_points.is_empty():
		return
	
	elif grapple_points.size() == 1:
		nearest_grapple_point = grapple_points.front()
	
	else:
		nearest_grapple_point = grapple_points.front()
		for grapple_point in grapple_points:
			if self.global_position.distance_to(nearest_grapple_point.global_position) > self.global_position.distance_to(grapple_point.global_position):
				nearest_grapple_point = grapple_point
	
	
	grappling = true
	initialize_grappling_mode()
	set_physics_process(true)
	$Rope.visible = true
	update_rope_transform(nearest_grapple_point.global_position)

func _physics_process(delta):
	if nearest_grapple_point != null:
		update_rope_transform(nearest_grapple_point.global_transform.origin)

func end_grapple():
	grappling = false
	set_physics_process(false)
	$Rope.visible = false
	#joint.queue_free()
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

func add_grapple_point(grapple_point):
	grapple_points.append(grapple_point)
	
func remove_grapple_point(grapple_point):
	grapple_points.erase(grapple_point)

func initialize_grappling_mode():
	match nearest_grapple_point.grapple_point_type:
		
		nearest_grapple_point.grapple_point_type_enum.PULL:
			#create joint
			joint = JoltSliderJoint3D.new()
			nearest_grapple_point.add_child(joint)
			joint.node_a = nearest_grapple_point.find_child("GrappleBody").get_path()
			joint.node_b = get_parent().get_parent()._physics_body.get_path()
			
		nearest_grapple_point.grapple_point_type_enum.SWING:
			#create joint
			#joint = JoltGeneric6DOFJoint3D.new()
			#print_debug(joint)
			joint = nearest_grapple_point.sdof
			
			#connect joint to bodies
			#nearest_grapple_point.add_child(joint)
			#joint.node_a = nearest_grapple_point.find_child("GrappleBody").get_path()
			joint.node_b = get_parent().get_parent()._physics_body.get_path()
			print(joint.node_b)
			
		nearest_grapple_point.grapple_point_type_enum.TUG:
			print(nearest_grapple_point.grapple_point_type_enum.TUG)
