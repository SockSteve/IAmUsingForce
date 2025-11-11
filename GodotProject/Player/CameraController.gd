class_name CameraController
extends Node3D

## Enhanced camera controller with smooth damping and better input handling
##
## This controller manages the PhantomCamera3D and provides:
## - Smooth positional and rotational damping
## - Mouse input with optional acceleration
## - Configurable sensitivity and response curves

#region Export Variables

@export_group("Mouse Input")
## Base mouse sensitivity multiplier
@export_range(0.0, 2.0, 0.01) var mouse_sensitivity: float = 0.25

## If enabled, mouse movement will feel more responsive at higher speeds
@export var mouse_acceleration: bool = false

## How much to accelerate mouse movement (only if mouse_acceleration is true)
@export_range(1.0, 3.0, 0.1) var mouse_acceleration_factor: float = 1.5

## Invert vertical mouse axis
@export var invert_mouse_y: bool = false

@export_group("Camera Rotation Limits")
## Minimum pitch angle (looking up)
@export var min_pitch: float = -89.9

## Maximum pitch angle (looking down)
@export var max_pitch: float = 50.0

## Minimum yaw angle (typically 0 for free rotation)
@export var min_yaw: float = 0.0

## Maximum yaw angle (typically 360 for free rotation)
@export var max_yaw: float = 360.0

@export_group("Camera Smoothing")
## Enable position damping for smoother camera movement
@export var enable_follow_damping: bool = true

## How quickly camera follows player (lower = smoother, higher = snappier)
## X = horizontal, Y = vertical, Z = depth
@export var follow_damping_value: Vector3 = Vector3(0.15, 0.15, 0.15)

## Enable rotation damping for smoother camera rotation
@export var enable_rotation_damping: bool = true

## How quickly camera rotates (lower = smoother, higher = snappier)
@export_range(0.001, 1.0, 0.001) var rotation_damping_value: float = 0.1

@export_group("Camera Distance")
## Distance from player (spring arm length)
@export_range(1.0, 20.0, 0.5) var camera_distance: float = 5.0

## Vertical offset from player position
@export_range(-2.0, 3.0, 0.1) var camera_height_offset: float = 1.5

#endregion

#region Node References

@onready var camera: Camera3D = %MainCamera
@onready var _player_pcam: PhantomCamera3D = $PlayerCamera

#endregion


#region Private Variables

var _last_mouse_velocity: Vector2 = Vector2.ZERO

#endregion


#region Lifecycle Methods

func _ready() -> void:
	_apply_camera_settings()

func _apply_camera_settings() -> void:
	"""Applies exported camera settings to PhantomCamera3D"""
	if not _player_pcam:
		push_warning("PlayerCamera PhantomCamera3D not found!")
		return

	# Apply follow damping
	_player_pcam.set_follow_damping(enable_follow_damping)
	_player_pcam.set_follow_damping_value(follow_damping_value)

	# Apply camera distance and offset
	_player_pcam.set_spring_length(camera_distance)
	_player_pcam.set_follow_offset(Vector3(0, camera_height_offset, 0))

	print("Camera settings applied:")
	print("  Follow Damping: ", enable_follow_damping, " Value: ", follow_damping_value)
	print("  Spring Length: ", camera_distance)
	print("  Follow Offset: ", Vector3(0, camera_height_offset, 0))

func _input(event: InputEvent) -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		_set_pcam_rotation(_player_pcam, event)

#endregion


#region Camera Rotation

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	"""Handles mouse input and applies rotation to PhantomCamera3D with optional acceleration"""
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3 = pcam.get_third_person_rotation_degrees()

		# Calculate base mouse delta
		var mouse_delta: Vector2 = event.relative

		# Apply mouse acceleration if enabled
		if mouse_acceleration:
			var velocity := mouse_delta.length()
			if velocity > 0:
				var acceleration := pow(velocity / 10.0, mouse_acceleration_factor - 1.0)
				mouse_delta *= acceleration

		# Apply sensitivity
		var adjusted_delta := mouse_delta * mouse_sensitivity

		# Apply inversion
		var y_multiplier := -1.0 if not invert_mouse_y else 1.0

		# Change the X rotation (pitch)
		pcam_rotation_degrees.x += adjusted_delta.y * y_multiplier
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation (yaw)
		pcam_rotation_degrees.y -= adjusted_delta.x
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Apply rotation to SpringArm3D
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

		# Store velocity for potential future use
		_last_mouse_velocity = mouse_delta

#endregion


#region Public Methods

## Updates camera distance at runtime
func set_camera_distance(distance: float) -> void:
	camera_distance = distance
	if _player_pcam:
		_player_pcam.set_spring_length(distance)

## Updates camera height offset at runtime
func set_camera_height_offset(height: float) -> void:
	camera_height_offset = height
	if _player_pcam:
		_player_pcam.set_follow_offset(Vector3(0, height, 0))

## Updates follow damping at runtime
func set_follow_damping_enabled(enabled: bool) -> void:
	enable_follow_damping = enabled
	if _player_pcam:
		_player_pcam.set_follow_damping(enabled)

## Updates follow damping value at runtime
func set_follow_damping_strength(value: Vector3) -> void:
	follow_damping_value = value
	if _player_pcam:
		_player_pcam.set_follow_damping_value(value)

## Gets reference to the PhantomCamera3D
func get_phantom_camera() -> PhantomCamera3D:
	return _player_pcam

#endregion
