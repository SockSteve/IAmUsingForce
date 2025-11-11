extends StaticBody3D
class_name ShootableTarget

## A target that can be shot and triggers camera shake
##
## This is a simple shootable object that emits camera shake
## when hit by bullets. Can be used for destructible objects,
## targets, or environmental interactions.

signal hit(position: Vector3, normal: Vector3)
signal destroyed

@export_group("Visual")
## Mesh to display
@export var mesh: Mesh:
	set(value):
		mesh = value
		if mesh_instance:
			mesh_instance.mesh = value

## Material to apply
@export var material: Material:
	set(value):
		material = value
		if mesh_instance:
			mesh_instance.material_override = value

@export_group("Behavior")
## Enable health system (object can be destroyed)
@export var destructible: bool = false

## Health points (only if destructible)
@export var max_health: int = 100

## Current health
var current_health: int = 100

@export_group("Camera Shake")
## Enable camera shake on hit
@export var enable_shake: bool = true

## Shake type (0=Light, 1=Medium, 2=Heavy, 3=Explosion)
@export_enum("Light", "Medium", "Heavy", "Explosion") var shake_type: int = 1

## Custom shake settings (overrides preset if enabled)
@export var use_custom_shake: bool = false
@export_range(0.0, 2.0, 0.05) var custom_amplitude: float = 0.3
@export_range(0.0, 5.0, 0.1) var custom_duration: float = 0.3

@export_group("Debug")
@export var show_hit_effects: bool = true

# Node references
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var camera_shake_emitter: CameraShakeEmitter

func _ready() -> void:
	_setup_nodes()
	_setup_collision_layer()

	if destructible:
		current_health = max_health

func _setup_nodes() -> void:
	"""Creates necessary child nodes"""
	# Create mesh instance
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	add_child(mesh_instance)

	if mesh:
		mesh_instance.mesh = mesh
	else:
		# Default box mesh if none provided
		var box = BoxMesh.new()
		box.size = Vector3(1, 1, 1)
		mesh_instance.mesh = box

	if material:
		mesh_instance.material_override = material

	# Create collision shape
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision_shape.shape = box_shape
	add_child(collision_shape)

	# Create camera shake emitter if enabled
	if enable_shake:
		camera_shake_emitter = CameraShakeEmitter.new()
		camera_shake_emitter.name = "CameraShakeEmitter"
		camera_shake_emitter.show_debug_sphere = show_hit_effects

		# Configure shake based on type
		if use_custom_shake:
			camera_shake_emitter.shake_amplitude = custom_amplitude
			camera_shake_emitter.shake_duration = custom_duration
		else:
			_configure_shake_preset()

		add_child(camera_shake_emitter)

func _setup_collision_layer() -> void:
	"""Setup collision layers for bullet detection"""
	# Set to layer 4 (Destructible) as per CLAUDE.md
	collision_layer = 1 << 3  # Layer 4
	# Collide with player bullets (layer 9)
	collision_mask = 1 << 8  # Layer 9

func _configure_shake_preset() -> void:
	"""Configures shake based on selected preset"""
	if not camera_shake_emitter:
		return

	match shake_type:
		0:  # Light
			camera_shake_emitter.shake_amplitude = 0.1
			camera_shake_emitter.shake_duration = 0.2
			camera_shake_emitter.shake_frequency = 25.0
		1:  # Medium
			camera_shake_emitter.shake_amplitude = 0.3
			camera_shake_emitter.shake_duration = 0.3
			camera_shake_emitter.shake_frequency = 30.0
		2:  # Heavy
			camera_shake_emitter.shake_amplitude = 0.6
			camera_shake_emitter.shake_duration = 0.5
			camera_shake_emitter.shake_frequency = 35.0
		3:  # Explosion
			camera_shake_emitter.shake_amplitude = 1.0
			camera_shake_emitter.shake_duration = 0.7
			camera_shake_emitter.shake_frequency = 40.0

## Called when a bullet hits this object
func on_bullet_hit(bullet: Node3D, hit_position: Vector3, hit_normal: Vector3) -> void:
	print("ShootableTarget hit at: ", hit_position)

	# Emit signal
	hit.emit(hit_position, hit_normal)

	# Emit camera shake
	if enable_shake and camera_shake_emitter:
		camera_shake_emitter.emit_shake()

	# Show hit effect
	if show_hit_effects:
		_show_hit_effect(hit_position, hit_normal)

	# Handle health/destruction
	if destructible:
		_take_damage(10)  # Default damage per hit

func _take_damage(amount: int) -> void:
	"""Reduces health and destroys if needed"""
	current_health -= amount
	print("Target health: ", current_health, "/", max_health)

	if current_health <= 0:
		_destroy()

func _destroy() -> void:
	"""Destroys the target"""
	print("Target destroyed!")
	destroyed.emit()

	# Big explosion shake
	if enable_shake and camera_shake_emitter:
		camera_shake_emitter.emit_explosion_shake()

	# Optionally hide or remove
	queue_free()

func _show_hit_effect(hit_pos: Vector3, hit_normal: Vector3) -> void:
	"""Visual feedback for hit"""
	# Flash the mesh briefly
	if mesh_instance:
		var mat = mesh_instance.get_active_material(0)
		if mat and mat is StandardMaterial3D:
			var original_color = mat.albedo_color
			var tween = create_tween()
			tween.tween_property(mat, "albedo_color", Color.RED, 0.1)
			tween.tween_property(mat, "albedo_color", original_color, 0.2)

## Trigger shake manually (useful for testing)
func trigger_shake() -> void:
	if camera_shake_emitter:
		camera_shake_emitter.emit_shake()
