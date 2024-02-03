extends Node3D
@onready var rope = $rope
@onready var start = $point1
@onready var end = $point2

# Called when the node enters the scene tree for the first time.
func _ready():
	var start_pos = start.global_transform.origin
	var direction = end.global_transform.origin - start_pos
	var rope_length = direction.length()
	rope.global_transform.origin = start_pos + direction / 2.0
	var look_at_transform = Transform3D.IDENTITY.looking_at(direction, Vector3.UP, false)
	rope.global_transform *= look_at_transform
	var desired_radius = 1  # Adjust as needed
	var scale = Vector3(desired_radius / rope.scale.x, rope_length, desired_radius / rope.scale.z)
	rope.scale = scale
	var additional_rotation_angle = 180.0
	rope.rotate(Vector3(1, 0, 0), deg_to_rad(additional_rotation_angle))
	#rope.rotate_x(PI/2)
	#rope.rotate_y(PI/2)
	#rope.rotate_z(PI/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var start_pos = start.global_transform.origin
	#var direction = end.global_transform.origin - start_pos
	#var rope_length = direction.length()
	#rope.global_transform.origin = start_pos + direction / 2.0
	#var look_at_transform = Transform3D.IDENTITY.looking_at(direction, Vector3.UP, false)
	#rope.global_transform *= look_at_transform
	#var desired_radius = 1  # Adjust as needed
	#var scale = Vector3(desired_radius / rope.scale.x, rope_length, desired_radius / rope.scale.z)
	#rope.scale = scale
	#rope.rotate_x(PI/4)
