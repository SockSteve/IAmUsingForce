extends Node3D


var id = "g01"

@onready var grapplePoints = get_tree().get_nodes_in_group("grapplingPoint")
var grapple_points : Array = []
var nearest_grapple_point
var grapple_point_global_position
var grappling: bool = false
var debug_grapple_distance = 600

enum {NULL, PULL, SWING}
var mode = NULL

func activate():
	if grapplePoints.is_empty():
		return
		
	var grappilingPointDistances := {}
	for grapplingPoint in grapplePoints:
		grapplingPoint.distance = owner.global_transform.origin.distance_to(grapplingPoint.global_position)
		grappilingPointDistances[grapplingPoint.distance] = grapplingPoint
		
	var closestGrapplingPoint = grappilingPointDistances[grappilingPointDistances.keys().min()]
	nearest_grapple_point = closestGrapplingPoint
	
	grapple_point_global_position = nearest_grapple_point.global_transform.origin
	
	set_physics_process(true)
	$Rope.visible = true
	update_rope_transform(nearest_grapple_point.global_position)
	if nearest_grapple_point.distance > debug_grapple_distance:
		return

func _ready():
	grapple_points.append_array(get_tree().get_nodes_in_group("grapplingPoint"))
	print(grapple_points)
	set_physics_process(false)
	#$Rope

func end_grapple():
	set_physics_process(false)
	$Rope.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if nearest_grapple_point != null:
		update_rope_transform(nearest_grapple_point.global_transform.origin)

func update_rope_transform(grapple_point_position: Vector3) -> void:
	var rope = $Rope # Adjust the path
	var gadget_pos = global_transform.origin
	var direction = grapple_point_position - gadget_pos
	
	var distance = direction.length()
	direction = direction.normalized()
	#rope.scale = Vector3(rope.scale.x, distance, rope.scale.z)
	rope.scale = Vector3(rope.scale.x, rope.scale.y, distance)
	#direction = direction.dot(nearest_grapple_point.transform.basis.z)
	#rope.scale.y = distance #/ rope.initial_length  # 'initial_length' is the original length of your rope mesh
	rope.look_at_from_position($Rope.global_position, grapple_point_position, Vector3.UP)
	#rope.look_at_from_position($Rope.global_position, grapple_point_global_position)
	#Basis.looking_at(direction, Vector3.UP)
	

