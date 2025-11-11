extends Decal
class_name DropShadow

## Dynamic drop shadow that only projects on the first surface below the player
## Uses raycasting to position the decal at the correct height

@export var max_distance: float = 20.0
@export var shadow_offset: float = 0.1  # Slight offset to prevent z-fighting
@export var fade_start_distance: float = 5.0
@export var fade_end_distance: float = 15.0
@export var debug_mode: bool = false

var raycast: RayCast3D
var player: Player

func _ready() -> void:
	# Get player reference
	player = get_parent() as Player
	if not player:
		push_error("DropShadow must be a child of Player")
		queue_free()
		return

	# Create and configure raycast as child of player (not decal)
	raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, -max_distance, 0)
	raycast.enabled = true
	raycast.collide_with_areas = false
	raycast.collide_with_bodies = true
	raycast.exclude_parent = true  # Don't hit the player itself

	# Set collision mask - try all walkable layers
	# Layers 6 (Floor) and 7 (Platform)
	raycast.collision_mask = (1 << 5) | (1 << 6)  # Bit shift for layers 6 and 7

	# Add raycast as child deferred to avoid tree setup issues
	player.add_child.call_deferred(raycast)

	if debug_mode:
		print("DropShadow: Initialized with collision_mask: ", raycast.collision_mask)
		print("DropShadow: Max distance: ", max_distance)

	# Configure initial decal size
	size = Vector3(1.5, 0.2, 1.5)  # Slightly larger and thicker for visibility

	# Ensure decal is visible initially
	visible = true

func _physics_process(_delta: float) -> void:
	if not raycast or not player:
		return

	# Wait until raycast is in the tree (deferred add_child)
	if not raycast.is_inside_tree():
		return

	# Position raycast at player position
	raycast.global_position = player.global_position

	# Force raycast update
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var hit_position = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		var distance = player.global_position.distance_to(hit_position)

		if debug_mode:
			print("DropShadow: Hit at distance ", distance, " normal: ", hit_normal)

		# Position decal at hit point with slight offset along normal
		global_position = hit_position + hit_normal * shadow_offset

		# Orient decal to surface normal (pointing down into surface)
		look_at_from_position(global_position, global_position + hit_normal, Vector3.UP)

		# Fade based on distance
		if distance < fade_start_distance:
			albedo_mix = 0.8
		elif distance > fade_end_distance:
			albedo_mix = 0.0
		else:
			var fade_factor = inverse_lerp(fade_start_distance, fade_end_distance, distance)
			albedo_mix = lerp(0.8, 0.0, fade_factor)

		visible = true
	else:
		if debug_mode:
			print("DropShadow: No collision detected")
		# No surface below, hide shadow
		visible = false
