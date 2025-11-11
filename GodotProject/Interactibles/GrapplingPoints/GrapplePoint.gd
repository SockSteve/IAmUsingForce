extends Node3D
class_name GrapplePoint

## Grapple point with optimized distance-based detection
## Only checks distance when visible on screen for best performance

# Type of grapple behavior at this point
enum grapple_point_type_enum {PULL, SWING, HOLD}
@export var grapple_point_type: grapple_point_type_enum = grapple_point_type_enum.SWING

# Detection settings
@export var detection_radius: float = 20.0

# Physics joint for connecting player to this point
@onready var grapple_joint: Generic6DOFJoint3D = $Generic6DOFJoint3D

# Swing/pull distance (for debug visualization)
@export var target_distance: float = 5.0

# Cached references
var player: Player = null
var detection_radius_squared: float = 0.0

# State tracking
var is_visible_on_screen: bool = false
var is_player_in_range: bool = false

# Debug visualization
var debug_enabled: bool = false
var debug_detection_sphere: MeshInstance3D = null
var debug_target_sphere: MeshInstance3D = null

func _ready():
	# Cache player reference
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

	# Pre-calculate squared radius for faster distance checks
	detection_radius_squared = detection_radius * detection_radius

	# Create debug visualization meshes (hidden by default)
	_create_debug_visuals()

	# Disable physics process until visible
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	# Only runs when visible on screen!
	if not player or not player.has_method("get_inventory"):
		return

	# Check if player has grappling hook gadget
	var inventory = player.get_inventory()
	if not inventory or not inventory.has_gadget("grappling_hook"):
		# Player doesn't have hook, no point checking distance
		if is_player_in_range:
			_notify_player_exit()
		return

	# Fast distance check using squared distance (avoids square root)
	var distance_sq = player.global_position.distance_squared_to(global_position)

	if distance_sq < detection_radius_squared:
		# Player entered range
		if not is_player_in_range:
			_notify_player_enter()
	else:
		# Player left range
		if is_player_in_range:
			_notify_player_exit()

func _notify_player_enter() -> void:
	is_player_in_range = true
	# Notify the grappling hook gadget
	var grappling_hook = player.get_inventory().get_gadget("grappling_hook")
	if grappling_hook and grappling_hook.has_method("add_grapple_point"):
		grappling_hook.add_grapple_point(self)
		grappling_hook.player = player  # Make sure hook knows about player
	print("GrapplePoint: Player in range")

func _notify_player_exit() -> void:
	is_player_in_range = false
	# Notify the grappling hook gadget
	var grappling_hook = player.get_inventory().get_gadget("grappling_hook")
	if grappling_hook and grappling_hook.has_method("remove_grapple_point"):
		grappling_hook.remove_grapple_point(self)
	print("GrapplePoint: Player out of range")

func _on_screen_entered() -> void:
	is_visible_on_screen = true
	set_physics_process(true)  # Start checking distance
	print("GrapplePoint: On screen - detection enabled")

func _on_screen_exited() -> void:
	is_visible_on_screen = false
	set_physics_process(false)  # Stop checking distance

	# Clean up if player was in range
	if is_player_in_range:
		_notify_player_exit()

	print("GrapplePoint: Off screen - detection disabled")

func get_joint() -> Joint3D:
	return grapple_joint

## Create debug visualization spheres
func _create_debug_visuals() -> void:
	# Detection radius sphere (outer, wireframe-ish)
	debug_detection_sphere = MeshInstance3D.new()
	var detection_mesh = SphereMesh.new()
	detection_mesh.radius = detection_radius
	detection_mesh.height = detection_radius * 2.0
	debug_detection_sphere.mesh = detection_mesh

	# Create transparent material for detection sphere
	var detection_material = StandardMaterial3D.new()
	detection_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	detection_material.albedo_color = Color(0.2, 0.8, 1.0, 0.2)  # Light blue, very transparent
	detection_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	detection_material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	debug_detection_sphere.material_override = detection_material

	add_child(debug_detection_sphere)
	debug_detection_sphere.visible = false

	# Target distance sphere (inner, more opaque)
	debug_target_sphere = MeshInstance3D.new()
	var target_mesh = SphereMesh.new()
	target_mesh.radius = target_distance
	target_mesh.height = target_distance * 2.0
	debug_target_sphere.mesh = target_mesh

	# Create material for target sphere
	var target_material = StandardMaterial3D.new()
	target_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	target_material.albedo_color = Color(1.0, 0.8, 0.2, 0.35)  # Orange/yellow, semi-transparent
	target_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	target_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	debug_target_sphere.material_override = target_material

	add_child(debug_target_sphere)
	debug_target_sphere.visible = false

## Toggle debug visualization on/off
func set_debug_enabled(enabled: bool) -> void:
	debug_enabled = enabled
	if debug_detection_sphere:
		debug_detection_sphere.visible = enabled
	if debug_target_sphere:
		debug_target_sphere.visible = enabled
