extends PathFollow3D

var grind_path: Path3D = null
var grinding
var velocity
var speed = 10

func start_grinding(path, path_follow):
	grinding = true
	velocity.y = 0

# Add these lines to attach the character to the path.
	grind_path = path
	#grind_path_follow = path_follow
	#grind_path_follow.add_child(self)

	# Calculate the closest point on the path to the player's current position.
	var closest_distance = INF
	var closest_index = 0
	var points = path.get_curve().get_baked_points()

	for i in range(points.size()):
		var distance = position.distance_to(points[i])
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i

	# Calculate the offset and assign it to the PathFollow node.
	var offset = float(closest_index) / points.size()
	#grind_path_follow.unit_offset = offset
	progress_ratio = offset


func stop_grinding():
	grinding = false

	# Add these lines to detach the character from the path.
	#grind_path_follow.remove_child(self)
	#grind_path = null
	#grind_path_follow = null

func _physics_process(delta):
	if grinding:
		# Move the character along the path.
		progress_ratio += speed * delta
	else:
		# ...
		pass
