class_name CameraController
extends Node3D

#enum CAMERA_PIVOT { OVER_SHOULDER, THIRD_PERSON, AIM }

#@export_node_path var player_path : NodePath
#@export var invert_mouse_y := false
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
#@export_range(0.0, 8.0) var joystick_sensitivity := 2.0
#@export var tilt_upper_limit := deg_to_rad(-60.0)
#@export var tilt_lower_limit := deg_to_rad(60.0)
#@export var tilt_speed := 1
#@export var rotation_speed := 1

@onready var camera: Camera3D = %MainCamera
@onready var _player_pcam: PhantomCamera3D = $PlayerCamera
#@onready var _over_shoulder_pivot: Node3D = $CameraOverShoulderPivot
#@onready var _camera_spring_arm: SpringArm3D = $CameraSpringArm
#@onready var _third_person_pivot: Node3D = $CameraSpringArm/CameraThirdPersonPivot
#@onready var _camera_raycast: RayCast3D = $PlayerCamera/CameraRayCast

#@export var mouse_sensitivity: float = 0.05

@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@export var min_yaw: float = 0
@export var max_yaw: float = 360


#var _aim_target : Vector3
#var _aim_collider: Node
#var _pivot: Node3D
#var _current_pivot_type: CAMERA_PIVOT
#var _rotation_input: float
#var _tilt_input: float
#var _mouse_input := false
#var _offset: Vector3
#var _anchor: CharacterBody3D
#var _euler_rotation: Vector3


#func _unhandled_input(event: InputEvent) -> void:
	#_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	#if _mouse_input:
		#_rotation_input = -event.relative.x * mouse_sensitivity
		#_tilt_input = -event.relative.y * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		var active_pcam: PhantomCamera3D

		_set_pcam_rotation(_player_pcam, event)
		#_set_pcam_rotation(_aim_pcam, event)
		#if _player_pcam.get_priority() > _aim_pcam.get_priority():
			#_toggle_aim_pcam(event)
		#else:
			#_toggle_aim_pcam(event)

		#if event is InputEventKey and event.pressed:
			#if event.keycode == KEY_SPACE:
				#if _ceiling_pcam.get_priority() < 30 and _player_pcam.is_active():
					#_ceiling_pcam.set_priority(30)
				#else:
					#_ceiling_pcam.set_priority(1)

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Change the SpringArm3D node's rotation and rotate around its target
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

#func _physics_process(delta: float) -> void:
	#if not _anchor:
		#return
#
	#_rotation_input += Input.get_action_raw_strength("camera_left") - Input.get_action_raw_strength("camera_right")
	#_tilt_input += Input.get_action_raw_strength("camera_up") - Input.get_action_raw_strength("camera_down")
#
	##mitigate stick drift
	#if _rotation_input < .1  and _rotation_input > -.1:
		#_rotation_input = 0
	#
	##mitigate stick drift
	#if _tilt_input < .1 and _tilt_input > -.1:
		#_tilt_input = 0
	#
	#if invert_mouse_y:
		#_tilt_input *= -1
#
	#if _camera_raycast.is_colliding():
		#_aim_target = _camera_raycast.get_collision_point()
		#_aim_collider = _camera_raycast.get_collider()
	#else:
		#_aim_target = _camera_raycast.global_transform * _camera_raycast.target_position
		#_aim_collider = null
#
	## Set camera controller to current ground level for the character
	#var target_position := _anchor.global_position + _offset
	#target_position.y = lerp(global_position.y, _anchor._ground_height, 0.1)
	#global_position = target_position
#
	## Rotates camera using euler rotation
	#_euler_rotation.x += _tilt_input * delta * tilt_speed
	#_euler_rotation.x = clamp(_euler_rotation.x, tilt_lower_limit, tilt_upper_limit)
	#_euler_rotation.y += _rotation_input * delta * rotation_speed
#
	#transform.basis = Basis.from_euler(_euler_rotation)
#
	#camera.global_transform = _pivot.global_transform
	#camera.rotation.z = 0
#
	#_rotation_input = 0.0
	#_tilt_input = 0.0


#func setup(anchor: CharacterBody3D) -> void:
	#_anchor = anchor
	#_offset = global_transform.origin - anchor.global_transform.origin
	#set_pivot(CAMERA_PIVOT.THIRD_PERSON)
	#camera.global_transform = camera.global_transform.interpolate_with(_pivot.global_transform, 0.1)
	#_camera_spring_arm.add_excluded_object(_anchor.get_rid())
	#_camera_raycast.add_exception_rid(_anchor.get_rid())


#func set_pivot(pivot_type: CAMERA_PIVOT) -> void:
	#if pivot_type == _current_pivot_type:
		#return
#
	#match(pivot_type):
		#CAMERA_PIVOT.OVER_SHOULDER:
			#_over_shoulder_pivot.look_at(_aim_target)
			#_pivot = _over_shoulder_pivot
		#CAMERA_PIVOT.THIRD_PERSON:
			#_pivot = _third_person_pivot
#
	#_current_pivot_type = pivot_type


#func get_aim_target() -> Vector3:
	#return _aim_target
#
#
#func get_aim_collider() -> Node:
	#if is_instance_valid(_aim_collider):
		#return _aim_collider
	#else:
		#return null
