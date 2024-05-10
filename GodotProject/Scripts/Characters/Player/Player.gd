"""
This is the player

"""

extends CharacterBody3D
class_name Player

@export_category("Gameplay")
@export_group("Base Movement")
@export var move_speed := 12.0 # Character maximum run speed on the ground.
@export var acceleration := 4.0 # Movement acceleration (how fast character achieve maximum speed)
@export var _rotation_speed := 12.0 # Player model rotaion speed
@export var stopping_speed := 4.5
@export var jump_apex_gravity := -10
@export var jump_initial_impulse := 12.0 # Jump impulse
@export var crouch_move_speed := 6.0
@export var crouch_acceleration := 2.0
@export var crouch_rotation_speed := 16.0
@export var crouch_jump_initial_impulse := 16.0 # Jump impulse
@export var slide_start_threshhold := 6
@export var slide_strength = 30.0
@export var slide_duration = .5
@export_group("Combat")
@export var attack_impulse := 100.0 # Forward impulse after a melee attack.
@export var max_throwback_force := 15.0 # Max throwback force after player takes a hit
@export var parry_window := .1
@export var block_time := 2.0
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export_group("Base Loadout")
@export var starting_loadout: PackedStringArray

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _physics_body: RigidBody3D = $PhysicsBody
@onready var _character_skin := $CharacterRotationRoot/CharacterSkin
@onready var hand = %PlayerHand
@onready var collision_shape: CollisionShape3D= $CollisionShape3D
@onready var ledge_ray_vertical: RayCast3D = find_child("LedgeRayVertical")
@onready var ledge_ray_horizontal: RayCast3D = find_child("LedgeRayHorizontal")
#@onready var _attack_animation_player: AnimationPlayer = $CharacterRotationRoot/MeleeAnchor/AnimationPlayer

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin
@onready var _is_on_floor_buffer := false

#debug
var combo_step : int = 0 #used for melee attack combo
var is_attacking : bool = false
var is_crouching = false
var is_sliding: bool = false
var freeze: bool = false

@onready var _is_grapple := false
@onready var state = $StateMachine.state
var magnetized = false
var grappling = false
@onready var inventory = $Inventory

@onready var slide_timer: Timer = $SlideTimer

var current_weapon: Node
var is_strafing: bool

var crouching_collision_height: float = .9
@onready var standing_collision_height: float = collision_shape.shape.height
@onready var standing_collision_position: Vector3 = Vector3(0,standing_collision_height/2,0)
@onready var crouching_collision_position: Vector3 = Vector3(0,crouching_collision_height/2,0)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)
	add_starting_loadout_to_inventory()
	put_in_hand(current_weapon)

func _physics_process(delta):
	#if Input.is_action_just_pressed("crouch"):
		#_ready()
	#print($StateMachine.state)
	# Calculate ground height for camera controller
	if _ground_shapecast.get_collision_count() > 0:
		for collision_result in _ground_shapecast.collision_result:
			_ground_height = max(_ground_height, collision_result.point.y)
	else:
		_ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < _ground_height:
		_ground_height = global_position.y
		
	if Input.is_action_just_pressed("gadget"):
		var random_weapon = inventory.get_random_weapon()
		put_in_hand(random_weapon)
		
	if Input.is_action_just_pressed("dodge"):
		is_strafing = !is_strafing

func _get_camera_oriented_input() -> Vector3:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	input = _camera_controller.global_transform.basis * input
	input.y = 0.0
	return input

"""
function for smoothly rotating the player towards a given direction
"""
func _orient_character_to_direction(direction: Vector3, delta: float,rotation_speed:float=_rotation_speed, up_vector: Vector3 = Vector3.UP) -> void:
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)

func _orient_magnetized_character_to_direction(direction: Vector3, delta: float,rotation_speed:float=_rotation_speed, up_vector: Vector3 = Vector3.UP) -> void:
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	self.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)

"""
function for changing the player physics to that of a ridgidbody (here @PhysicsBody)
called in - @Node StateMachine
"""
func switchToPhysicsBody():
	var stored_player_velocity = velocity
	_physics_body.linear_velocity 
	_physics_body.global_transform = self.global_transform
	_physics_body.freeze = false
	_physics_body.top_level = true
	_physics_body.linear_velocity = stored_player_velocity

"""
function to switch the physics back to that of a CharacterBody3D
called in - @Node StateMachine
"""
func switchToCharacterBody():
	_physics_body.freeze = true
	_physics_body.top_level = false
	velocity = _physics_body.linear_velocity

func get_gadget(gadget: String):
	return inventory.get_gadget(gadget)

func add_gadget(gadget):
	inventory.add_gadget(gadget)

#function for putting a weapon in hand - called from player hand
func put_in_hand(weapon_or_gadget: Node):
	hand.add_or_replace_item_to_hand(weapon_or_gadget)
	_character_skin.change_weapon(weapon_or_gadget.name)

func attack():
	pass

"""
function for adding the initial weapon loadout to the inventory.
	#@param starting_loadout - defined as export PackedStringArray
	#@param weapon_path - path to be loaded, instantiated and added to the inventory
"""
func add_starting_loadout_to_inventory():
	for weapon_path in starting_loadout:
		var weapon_scene = load(weapon_path)
		weapon_scene = weapon_scene.instantiate()
		if current_weapon == null:
			current_weapon = weapon_scene
		
		inventory.add_weapon(weapon_scene.name, weapon_scene)
