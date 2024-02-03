extends CharacterBody3D
class_name Player

@export_category("test")
@export_group("test")
@export var move_speed := 12.0 # Character maximum run speed on the ground.
@export var attack_impulse := 10.0 # Forward impulse after a melee attack.
@export var acceleration := 4.0 # Movement acceleration (how fast character achieve maximum speed)
@export var jump_initial_impulse := 12.0 # Jump impulse
@export var jump_apex_gravity := -10
@export_subgroup("sub")
@export var jump_additional_force := 4.5 # Jump impulse when player keeps pressing jump
@export var rotation_speed := 12.0 # Player model rotaion speed
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export var stopping_speed := 4.5

@export var max_throwback_force := 15.0 # Max throwback force after player takes a hit
@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
#@onready var _attack_animation_player: AnimationPlayer = $CharacterRotationRoot/MeleeAnchor/AnimationPlayer
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _physics_body: RigidBody3D = $PhysicsBody

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin
@onready var _character_skin := $CharacterRotationRoot/CharacterSkin

@onready var _is_on_floor_buffer := false
@onready var _is_grapple := false

#debug
#var physicsBodyEnabled := false
@onready var state = $StateMachine.state
var magnetized = false
var grappling = false
@onready var inventory = $Inventory
@onready var grapplingHook = $Inventory/Gadgets/GrapplingHook
@onready var GrindBoots = $Inventory/Gadgets/GrindBoots
var shortcutRangedWeapons
@onready var current_weapon = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)

func _physics_process(delta):
	#print($StateMachine.state)
	# Calculate ground height for camera controller
	if _ground_shapecast.get_collision_count() > 0:
		for collision_result in _ground_shapecast.collision_result:
			_ground_height = max(_ground_height, collision_result.point.y)
	else:
		_ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < _ground_height:
		_ground_height = global_position.y
	
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	#if _move_direction.length() > 0.2:
		#_last_strong_direction = _move_direction.normalized()
	#if is_aiming:
		#_last_strong_direction = (_camera_controller.global_transform.basis * Vector3.BACK).normalized()

	#_orient_character_to_direction(_last_strong_direction, delta)

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
	_physics_body.linear_velocity = velocity
	_physics_body.global_transform = self.global_transform
	_physics_body.freeze = false
	_physics_body.top_level = true

func switchToCharacterBody():
	_physics_body.freeze = true
	_physics_body.top_level = false
	velocity = _physics_body.linear_velocity

func get_gadget(gadget: String):
	return inventory.get_gadget(gadget)

func attack():
	pass
	
func performMeleeAttack():
	pass

func performRangedAttack():
	pass

