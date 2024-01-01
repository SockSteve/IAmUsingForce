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
#@onready var _grenade_aim_controller: GrenadeLauncher = $GrenadeLauncher
#@onready var _character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin
#@onready var _ui_aim_recticle: ColorRect = %AimRecticle
#@onready var _ui_coins_container: HBoxContainer = %CoinsContainer
#@onready var _step_sound: AudioStreamPlayer3D = $StepSound
#@onready var _landing_sound: AudioStreamPlayer3D = $LandingSound

#@onready var _equipped_weapon: WEAPON_TYPE = WEAPON_TYPE.DEFAULT
@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin
#@onready var _coins := 0
@onready var _is_on_floor_buffer := false
@onready var _is_grapple := false

@onready var _shoot_cooldown_tick := shoot_cooldown
@onready var _grenade_cooldown_tick := grenade_cooldown

var gravity = -30.0 
var physicsBodyEnabled := false

@onready var grapplePoints = get_tree().get_nodes_in_group("grapplingPoint")

@onready var state = $StateMachine.state

var grapple_points = []
var grinding = false

var shortcutRangedWeapons

func _ready() -> void:
	grapple_points.append_array(get_tree().get_nodes_in_group("grapplingPoint"))
	print(grapple_points)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)
	#_grenade_aim_controller.visible = false
	#emit_signal("weapon_switched", WEAPON_TYPE.keys()[0])

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



	# Set character animation
#	if is_just_jumping:
#		_character_skin.jump()
#	elif not is_on_floor() and velocity.y < 0:
#		_character_skin.fall()
#	elif is_on_floor():
#		var xz_velocity := Vector3(velocity.x, 0, velocity.z)
#		if xz_velocity.length() > stopping_speed:
#			_character_skin.set_moving(true)
#			_character_skin.set_moving_speed(inverse_lerp(0.0, move_speed, xz_velocity.length()))
#		else:
#			_character_skin.set_moving(false)


func _get_camera_oriented_input() -> Vector3:
#	if _attack_animation_player.is_playing():
#		return Vector3.ZERO

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

func disableGravity():
	_gravity = 0.0
	
func enableGravity():
	_gravity = -30.0

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
#
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

#var move_speed = 10.0
var RAY_LENGTH: float = 2.0
var distance_from_center: float = 2.5
var position_offset_y: float = .1
var max_rotation_degrees: float = 5

@onready var space_state = get_world_3d().direct_space_state


func positionOnTerrain(left_hit, right_hit):
	var average_normal = (left_hit.normal + right_hit.normal).normalized()
	var average_point = (left_hit.position + right_hit.position) / 2
	
	var target_rotation = average_normal.rotation_to(Vector3.UP)
	var current_rotation = global_transform.basis.get_rotation_quaternion()
	var final_rotation = current_rotation.slerp(target_rotation, max_rotation_degrees * PI / 180.0)
	
	global_transform.basis = final_rotation
	global_transform.origin = average_point + global_transform.basis.y * position_offset_y
