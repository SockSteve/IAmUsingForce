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
		grapplingPoint.distance = owner.global_transform.origin.distance_to(grapplingPoint.get_grapplingpoint_position())
		grappilingPointDistances[grapplingPoint.distance] = grapplingPoint
		
	var closestGrapplingPoint = grappilingPointDistances[grappilingPointDistances.keys().min()]
	nearest_grapple_point = closestGrapplingPoint
	
	grapple_point_global_position = nearest_grapple_point.global_position
	if nearest_grapple_point.distance > debug_grapple_distance:
		return

func _ready():
	grapple_points.append_array(get_tree().get_nodes_in_group("grapplingPoint"))
	print(grapple_points)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
