extends CharacterBody3D
class_name Player

@export_category("Gameplay")
@export_group("Base Movement")
@export var move_speed := 12.0 # Character maximum run speed on the ground.
@export var acceleration := 4.0 # Movement acceleration (how fast character achieve maximum speed)
@export var crouch_move_speed := 6.0
@export var jump_initial_impulse := 12.0 # Jump impulse
@export var crouch_jump_initial_impulse := 16.0 # Jump impulse
#@export var jump_additional_force := 4.5 # Jump impulse when player keeps pressing jump
@export var jump_apex_gravity := -10
@export var stopping_speed := 4.5
@export var rotation_speed := 12.0 # Player model rotaion speed
@export_group("Combat")
@export var attack_impulse := 10.0 # Forward impulse after a melee attack.
@export var max_throwback_force := 15.0 # Max throwback force after player takes a hit
@export var parry_window := .1
@export var block_time := 2.0
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _physics_body: RigidBody3D = $PhysicsBody
@onready var _character_skin := $CharacterRotationRoot/CharacterSkin
#@onready var _attack_animation_player: AnimationPlayer = $CharacterRotationRoot/MeleeAnchor/AnimationPlayer

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin

@onready var _is_on_floor_buffer := false

#debug
#var physicsBodyEnabled := false
var combo_step : int = 0 #used for melee attack combo
var is_attacking : bool = false
var weapon

@onready var _is_grapple := false
@onready var state = $StateMachine.state
var magnetized = false
var grappling = false
@onready var inventory = $Inventory
@onready var current_weapon = null
#slide
@export var slide_strength = 30.0
var slide_velocity = Vector3(0, 0, -slide_strength)  # The Z-axis is assumed to be the forward axis.  # Adjust the strength and direction
var slide_duration = .5  # Adjust duration as needed
var sliding: bool = false
var freeze: bool = false
@onready var slide_timer = $SlideTimer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)

func _physics_process(delta):
	if Input.is_action_just_pressed("crouch"):
		_ready()
	#print($StateMachine.state)
	# Calculate ground height for camera controller
	if _ground_shapecast.get_collision_count() > 0:
		for collision_result in _ground_shapecast.collision_result:
			_ground_height = max(_ground_height, collision_result.point.y)
	else:
		_ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < _ground_height:
		_ground_height = global_position.y

func _get_camera_oriented_input() -> Vector3:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	input = _camera_controller.global_transform.basis * input
	input.y = 0.0
	return input

func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)

func switchToPhysicsBody():
	var stored_player_velocity = velocity
	_physics_body.linear_velocity 
	_physics_body.global_transform = self.global_transform
	_physics_body.freeze = false
	_physics_body.top_level = true
	_physics_body.linear_velocity = stored_player_velocity

func switchToCharacterBody():
	_physics_body.freeze = true
	_physics_body.top_level = false
	velocity = _physics_body.linear_velocity

func get_gadget(gadget: String):
	return inventory.get_gadget(gadget)
	
func add_gadget(gadget):
	inventory.add_gadget(gadget)

func put_in_hand(weapon_or_gadget):
	pass

func attack():
	pass
	
func performMeleeAttack():
	pass

func performRangedAttack():
	pass

