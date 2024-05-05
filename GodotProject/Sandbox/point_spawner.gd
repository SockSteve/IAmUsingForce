extends Node3D

@onready var marker = preload("res://Scenes/Debug/DB_Marker3D.tscn")


func _ready():
	var i = 0
	while i <=200:
		i += 1
		var mi= marker.instantiate()
		add_child(mi)
		place_marker(mi)

func place_marker(mi):
	# Set its position
	mi.global_position = HelperLibrary.get_random_point_in_3d_area(self, 2, 5.0)
	
