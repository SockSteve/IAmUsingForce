extends CharacterBody3D
class_name Player


@export var move_speed := 8.0 # Character maximum run speed on the ground.
@export var attack_impulse := 10.0 # Forward impulse after a melee attack.
@export var acceleration := 4.0 # Movement acceleration (how fast character achieve maximum speed)
@export var jump_initial_impulse := 12.0 # Jump impulse
@export var jump_additional_force := 4.5 # Jump impulse when player keeps pressing jump
@export var rotation_speed := 12.0 # Player model rotaion speed

## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export var stopping_speed := 1.0
@export var max_throwback_force := 15.0 # Max throwback force after player takes a hit
@export var shoot_cooldown := 0.5 # Projectile cooldown
@export var grenade_cooldown := 0.5 # Grenade cooldown

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _attack_animation_player: AnimationPlayer = $CharacterRotationRoot/MeleeAnchor/AnimationPlayer
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _physics_body: RigidBody3D = $PhysicsBody
@onready var _grindBoots: PathFollow3D = $Inventory/Gadgets/GrindBoots
@onready var _currentGrindRail: Path3D = null



@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin

@onready var _is_on_floor_buffer := false
@onready var _is_grapple := false

#debug
var physicsBodyEnabled := false
@onready var state = $StateMachine.state
var grinding = false
@onready var grapplingHook = $Inventory/Gadgets/GrapplingHook
var shortcutRangedWeapons

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
	
	
	if physicsBodyEnabled:
		velocity = _physics_body.linear_velocity
		move_and_slide()
		return
		
	if get_last_slide_collision() != null:
		#print(get_last_slide_collision().get_collider().is_in_group("grindRail"))
		if get_last_slide_collision().get_collider().is_in_group("grindRail"):
			_currentGrindRail = get_last_slide_collision().get_collider().get_child(0)
			#print(_currentGrindRail)
			grinding = true

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	#if is_aiming:
		#_last_strong_direction = (_camera_controller.global_transform.basis * Vector3.BACK).normalized()

	_orient_character_to_direction(_last_strong_direction, delta)

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
	self.set_collision_layer_value(1,false)
	self.set_collision_mask_value(1, false)
	_physics_body.set_collision_layer_value(1,true)
	_physics_body.set_collision_mask_value(1,true)
	_physics_body.linear_velocity = velocity
	_physics_body.global_position = self.global_transform.origin
	_physics_body.freeze = false
	physicsBodyEnabled = true
	_physics_body.top_level = true

func switchToCharacterBody():
	self.set_collision_layer_value(1,true)
	self.set_collision_mask_value(1, true)
	_physics_body.set_collision_layer_value(1,false)
	_physics_body.set_collision_mask_value(1,false)
	_physics_body.global_position = self.global_transform.origin
	physicsBodyEnabled = false
	_physics_body.freeze = true
	_physics_body.top_level = false
	velocity = _physics_body.linear_velocity

func getGadgets():
	return $Inventory/Gadgets

func attack():
	pass
	
func performMeleeAttack():
	pass

func performRangedAttack():
	pass
