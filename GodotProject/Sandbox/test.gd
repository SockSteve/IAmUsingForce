extends Node3D
@onready var mi1: MeshInstance3D = $MeshInstance3D
@onready var mi2: MeshInstance3D = $MeshInstance3D2
var time_var = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_var += delta * .2
	mi1.global_position = mi1.global_position.lerp(mi2.global_position, time_var)
