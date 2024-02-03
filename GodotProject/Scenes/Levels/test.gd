extends MeshInstance3D

@onready var hook = $"../../SwingHook"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rope = $MeshInstance3D2 # Adjust the path
	var gadget_pos = global_transform.origin
	var direction = gadget_pos - hook.global_transform.origin
	var distance = direction.length()*10
	direction = direction.normalized()
	#rope.scale = Vector3(rope.scale.x, distance, rope.scale.z)
	#rope.scale = Vector3(distance, rope.scale.y, rope.scale.z)
	rope.scale = Vector3(rope.scale.x, rope.scale.y, distance)
	#rope.scale.y = distance #/ rope.initial_length  # 'initial_length' is the original length of your rope mesh
	rope.look_at_from_position(global_position, hook.global_transform.origin, Vector3.UP, true)
	
