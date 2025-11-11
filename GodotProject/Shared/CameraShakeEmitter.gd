extends Node3D
class_name CameraShakeEmitter

## Emits camera shake using Phantom Camera's noise system
##
## This component can be attached to any object to emit camera shake
## when triggered. Uses PhantomCameraNoiseEmitter3D for localized shake.

@export_group("Shake Settings")
## Amplitude of the shake (how far camera moves)
@export_range(0.0, 2.0, 0.05) var shake_amplitude: float = 0.3

## Frequency of the shake (how fast it oscillates)
@export_range(0.0, 100.0, 1.0) var shake_frequency: float = 30.0

## Duration of the shake in seconds
@export_range(0.0, 5.0, 0.1) var shake_duration: float = 0.3

## How quickly shake decays (trauma decrease per second)
@export_range(0.0, 10.0, 0.1) var decay_rate: float = 3.0

## Maximum distance shake can be felt from
@export_range(0.0, 100.0, 1.0) var max_distance: float = 20.0

## Which noise emitter layer to use (must match PhantomCamera3D noise_emitter_layer)
@export_flags_3d_render var noise_emitter_layer: int = 1

@export_group("Visual Feedback")
## Show debug sphere when shake is emitted
@export var show_debug_sphere: bool = false

## Color of debug sphere
@export var debug_color: Color = Color.ORANGE_RED

var _noise_emitter: Node3D
var _debug_sphere: MeshInstance3D

func _ready() -> void:
	_create_noise_emitter()
	if show_debug_sphere:
		_create_debug_sphere()

func _create_noise_emitter() -> void:
	"""Creates PhantomCameraNoiseEmitter3D node dynamically"""
	# Load the PhantomCameraNoiseEmitter3D script
	var noise_emitter_script = load("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_3d.gd")

	if not noise_emitter_script:
		push_error("Could not load PhantomCameraNoiseEmitter3D script!")
		return

	# Create the emitter node
	_noise_emitter = Node3D.new()
	_noise_emitter.set_script(noise_emitter_script)
	_noise_emitter.name = "NoiseEmitter"
	add_child(_noise_emitter)

	# Configure the emitter
	_noise_emitter.set("noise_emitter_layer", noise_emitter_layer)
	_noise_emitter.set("continuous", false)
	_noise_emitter.set("growth_time", 0.0)
	_noise_emitter.set("decay_time", 0.1)

	print("Camera shake emitter created at: ", get_path())

func _create_debug_sphere() -> void:
	"""Creates a debug visualization sphere"""
	_debug_sphere = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6

	var material = StandardMaterial3D.new()
	material.albedo_color = debug_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.5
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	_debug_sphere.mesh = sphere
	_debug_sphere.material_override = material
	_debug_sphere.visible = false
	add_child(_debug_sphere)

## Emits a camera shake with the configured settings
func emit_shake(custom_amplitude: float = -1.0, custom_duration: float = -1.0) -> void:
	if not _noise_emitter:
		push_warning("No noise emitter available!")
		return

	var amplitude = custom_amplitude if custom_amplitude >= 0 else shake_amplitude
	var duration = custom_duration if custom_duration >= 0 else shake_duration

	# Create noise resource
	var noise_resource_script = load("res://addons/phantom_camera/scripts/resources/phantom_camera_noise_3d.gd")
	var noise = noise_resource_script.new()

	# Configure noise
	noise.set("amplitude", amplitude)
	noise.set("frequency", shake_frequency)
	noise.set("trauma", 1.0)  # Start at max intensity
	noise.set("trauma_decay_rate", decay_rate)

	# Set the noise resource on the emitter
	_noise_emitter.set("noise", noise)
	_noise_emitter.set("duration", duration)

	# Emit the shake
	_noise_emitter.call("emit")

	# Show debug feedback
	if show_debug_sphere and _debug_sphere:
		_show_debug_feedback()

## Stops the current shake immediately
func stop_shake() -> void:
	if _noise_emitter:
		_noise_emitter.call("stop", false)

func _show_debug_feedback() -> void:
	"""Flash the debug sphere briefly"""
	if not _debug_sphere:
		return

	_debug_sphere.visible = true
	var tween = create_tween()
	tween.tween_property(_debug_sphere, "scale", Vector3.ONE * 1.5, 0.1)
	tween.tween_property(_debug_sphere, "scale", Vector3.ONE, 0.2)
	tween.tween_callback(func(): _debug_sphere.visible = false)

## Presets for common shake types

func emit_light_shake() -> void:
	"""Light shake for small impacts"""
	emit_shake(0.1, 0.2)

func emit_medium_shake() -> void:
	"""Medium shake for normal impacts"""
	emit_shake(0.3, 0.3)

func emit_heavy_shake() -> void:
	"""Heavy shake for large impacts"""
	emit_shake(0.6, 0.5)

func emit_explosion_shake() -> void:
	"""Intense shake for explosions"""
	emit_shake(1.0, 0.7)
