## GrapplingHook gadget - Active gadget with centralized grapple point management
## This class manages all grapple point detection and availability
## The actual grapple physics logic is in the Grapple state

extends Gadget

# Detected grapple points within range
var grapple_points: Array[GrapplePoint] = []
var nearest_grapple_point: GrapplePoint = null

# Player reference (set by inventory when gadget is added)
var player: Player = null

# Rope visual
var direction_normal_to_origin: Vector3 = Vector3.ZERO

func _ready():
	set_physics_process(false)

#here we test if any grappling points are in reach
#and if any grappling points are there, we set the player state bool and put it in the players hand
func activate():
	
	if grapple_points.is_empty():
		return
	
	if player == null:
		return
	
	if grapple_points.size() == 1:
		nearest_grapple_point = grapple_points.front()
	
	else:
		# Find nearest grapple point based on player position
		# (gadget might not be in tree yet, but player is)
		nearest_grapple_point = grapple_points.front()
		var player_pos = player.global_position

		for grapple_point in grapple_points:
			if player_pos.distance_to(nearest_grapple_point.global_position) > player_pos.distance_to(grapple_point.global_position):
				nearest_grapple_point = grapple_point
	
	#saveguard
	if nearest_grapple_point == null:
		return
	
	if not player.is_grappling:
		player.is_grappling = true
		# Put grappling hook in player's hand via weapon manager
		if player.weapon_manager:
			player.weapon_manager.equip_item(self)
		# Don't initialize joint yet - let Grapple state do it after pull-in!
		# initialize_grappling_mode() is now called from Grapple state
		set_physics_process(true)
		$Rope.visible = true
		update_rope_transform(nearest_grapple_point.global_position)

#physics_process is only used for the rope here
func _physics_process(_delta):
	if nearest_grapple_point != null:
		update_rope_transform(nearest_grapple_point.global_transform.origin)

func end_grapple():
	player.is_grappling = false
	set_physics_process(false)
	$Rope.visible = false

	# Clear the joint connection
	if nearest_grapple_point and nearest_grapple_point.grapple_joint:
		nearest_grapple_point.grapple_joint.node_b = NodePath()

	# Clear the nearest grapple point reference
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


# Called by GrapplePoints when player enters their range
func add_grapple_point(point: GrapplePoint) -> void:
	if not grapple_points.has(point):
		grapple_points.append(point)
		print("GrapplingHook: Grapple point available - Total: ", grapple_points.size())

# Called by GrapplePoints when player exits their range
func remove_grapple_point(point: GrapplePoint) -> void:
	grapple_points.erase(point)
	print("GrapplingHook: Grapple point unavailable - Total: ", grapple_points.size())

	# If we lost the currently targeted point, clear it
	if nearest_grapple_point == point:
		nearest_grapple_point = null

#when the grappling hook successfully activates this function is called
#it is responsible for assigning the player to the grapple joint
func initialize_grappling_mode():
	nearest_grapple_point.grapple_joint.node_b = player.physics_body.get_path()
	#joint.node_b = player.physics_body.get_path()
	
	#match nearest_grapple_point.grapple_point_type:
		#
		#nearest_grapple_point.grapple_point_type_enum.PULL:
			#joint = nearest_grapple_point.get_joint()
			#joint.node_b = player._physics_body.get_path()
			#
		#nearest_grapple_point.grapple_point_type_enum.SWING:
			#joint = nearest_grapple_point.get_joint()
			#joint.node_b = player._physics_body.get_path()
			#
		#nearest_grapple_point.grapple_point_type_enum.HOLD:
			#joint = nearest_grapple_point.get_joint()
			#push_warning("Tog: TODO")
