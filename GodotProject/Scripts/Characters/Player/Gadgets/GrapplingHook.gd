extends Node3D

@onready var grapplePoints = get_tree().get_nodes_in_group("grapplingPoint")
var grapple_points = []
var grappling: bool = false

func _ready():
	grapple_points.append_array(get_tree().get_nodes_in_group("grapplingPoint"))
	print(grapple_points)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
