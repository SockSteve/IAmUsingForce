extends Node
class_name PlayerInputHandler

## Handles all player input and translates it to game actions
## Separates input handling from game logic

signal movement_input_changed(direction: Vector3)
signal jump_pressed()
signal attack_pressed(attack_type: String)
signal dodge_pressed()
signal crouch_pressed()
signal interact_pressed()
signal strafe_toggled(enabled: bool)
signal quick_select_pressed(direction: String)
signal quick_select_panel_changed()
signal gadget_used()

@export var camera_controller: CameraController

var is_strafing: bool = false

func _ready() -> void:
	if not camera_controller:
		camera_controller = get_node("../CameraController") if has_node("../CameraController") else null

func _physics_process(_delta: float) -> void:
	_handle_movement_input()
	_handle_action_inputs()

func setup_input() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _handle_movement_input() -> void:
	var input_direction = _get_camera_oriented_input()
	movement_input_changed.emit(input_direction)

func _handle_action_inputs() -> void:
	# Movement actions
	if Input.is_action_just_pressed("jump"):
		jump_pressed.emit()
	
	if Input.is_action_just_pressed("dodge"):
		dodge_pressed.emit()
	
	if Input.is_action_just_pressed("crouch"):
		crouch_pressed.emit()
	
	# Combat actions
	if Input.is_action_just_pressed("melee_attack"):
		attack_pressed.emit("melee")
	
	if Input.is_action_just_pressed("ranged_attack"):
		attack_pressed.emit("ranged")
	
	# Interaction
	if Input.is_action_just_pressed("interact"):
		interact_pressed.emit()
	
	if Input.is_action_just_pressed("gadget"):
		gadget_used.emit()
	
	# Strafe toggle
	if Input.is_action_just_pressed("strafe"):
		is_strafing = not is_strafing
		strafe_toggled.emit(is_strafing)
	
	# Quick select
	if Input.is_action_just_pressed("quick_select_up"):
		quick_select_pressed.emit("up")
	
	if Input.is_action_just_pressed("quick_select_left"):
		quick_select_pressed.emit("left")
	
	if Input.is_action_just_pressed("quick_select_right"):
		quick_select_pressed.emit("right")
	
	if Input.is_action_just_pressed("quick_select_down"):
		quick_select_pressed.emit("down")
	
	if Input.is_action_just_pressed("quick_select_change_panel"):
		quick_select_panel_changed.emit()

func _get_camera_oriented_input() -> Vector3:
	if not camera_controller or not camera_controller.camera:
		return Vector3.ZERO

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input := Vector3.ZERO

	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	# Get only the horizontal rotation from the camera
	var camera_basis = camera_controller.camera.global_transform.basis
	var forward = camera_basis.z
	var right = camera_basis.x

	# Project vectors onto the horizontal plane
	forward.y = 0.0
	right.y = 0.0

	# Normalize to maintain consistent length
	forward = forward.normalized()
	right = right.normalized()

	# Create a new horizontal-only basis
	var horizontal_basis = Basis(right, Vector3.UP, forward)

	# Use this horizontal basis for movement
	input = (horizontal_basis * input).normalized()

	return input

## Get camera-oriented input (public for state machine access)
func get_camera_oriented_input() -> Vector3:
	return _get_camera_oriented_input()

## Get current strafe state
func get_strafe_state() -> bool:
	return is_strafing
