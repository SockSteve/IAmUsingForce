## This is the Player class script
## everything regarding the player lives here
## the player also functions as an interface for everything connected to it, like
## the inventory
extends CharacterBody3D
class_name Player

signal weapon_changed(weapon_name)

@export_category("Gameplay")
@export_group("Base Movement")
@export var move_speed := 12.0 ## Character maximum movement speed on the ground.
@export var acceleration := 4.0 ## Movement acceleration. How fast character achieve maximum speed.
@export var _rotation_speed := 12.0 ## Player model rotaion speed. Used to rotate @CharacterRotationRoot
@export var stopping_speed := 4.5
@export var jump_apex_gravity := -10
@export var jump_initial_impulse := 12.0 # Jump impulse
@export var crouch_move_speed := 6.0
@export var crouch_acceleration := 2.0
@export var crouch_rotation_speed := 16.0
@export var crouch_jump_initial_impulse := 16.0 # Jump impulse
@export var slide_start_threshhold := 6
@export var slide_strength_curve: Curve
@export var slide_strength_curve_factor = 1
@export var slide_strength_curve_time_factor = 1

@export_group("Combat")
@export var attack_impulse := 100.0 # Forward impulse after a melee attack.
@export var max_throwback_force := 15.0 # Max throwback force after player takes a hit
@export var parry_window := .1
@export var block_time := 2.0

@export_group("Base Loadout")
@export var starting_loadout: PackedStringArray

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _physics_body: RigidBody3D = $PhysicsBody
@onready var _character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin
@onready var hand = %PlayerHand
@onready var collision_shape: CollisionShape3D= $CollisionShape3D
@onready var ledge_ray_vertical: RayCast3D = find_child("LedgeRayVertical")
@onready var ledge_ray_horizontal: RayCast3D = find_child("LedgeRayHorizontal")
@onready var attack_timer: Timer = $AttackTimer
@onready var combo_timer: Timer = $ComboTimer

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin
@onready var _is_on_floor_buffer := false
@onready var state = $StateMachine.state
@onready var inventory = $Inventory
var crouching_collision_height: float = .9
@onready var standing_collision_height: float = collision_shape.shape.height
@onready var standing_collision_position: Vector3 = Vector3(0,standing_collision_height/2,0)
@onready var crouching_collision_position: Vector3 = Vector3(0,crouching_collision_height/2,0)

#state variables
var combo_step : int = 0 #used for melee attack combo
var can_melee: bool = false
var is_melee : bool = false
var attack_step_finished: bool = true
var is_crouching: bool = false
var is_sliding: bool = false
var can_grind: bool = true
var is_grinding: bool = false
var is_grappling: bool = false
var is_ledge_grabbing: bool = false
var is_hanging: bool = false
var is_magnetized: bool = false
var is_strafing: bool
var freeze: bool = false
var putting_ranged_weapon_in_hand_enabled: bool = true 

## store the active weapons that are not in the scene tree
var current_ranged_weapon: Node
var current_melee_weapon: Node

## weapon that is in the scene tree. there is only one.
var currently_held_weapon_or_gadget: Node
## stores currently_held_weapon_or_gadget weapon on gadget use. This need to be done in order to
## change back to the previously held weapon when the gadget use is over
var stored_weapon_on_gadget_use: Node #this variable is only assigned with the active weapon when a gadget is used. it stores the weapon so it can be placed back into the players hand fter the gadget usage is over.

#debug
@onready var grappling_hook = preload("res://Scenes/Gadgets/GrapplingHook/GrapplingHook.tscn").instantiate()
@onready var grinding_boots = preload("res://Scenes/Gadgets/GrindBoots/GrindBoots.tscn").instantiate()

func _ready() -> void:
	set_up_input()
	add_starting_loadout_to_inventory()
	print("Populating shortcut menu...")
	inventory.populate_quick_select_menu()
	put_in_hand(currently_held_weapon_or_gadget)
	inventory.add_gadget(grappling_hook.name, grappling_hook)
	inventory.add_gadget(grinding_boots.name, grinding_boots)
	
func set_up_input():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)

func _physics_process(delta)-> void:
	#uncomment the following fr debugging sates
	#print($StateMachine.state)
	
	#print("current weapon: ", currently_held_weapon_or_gadget)
	#print("melee weapon ", current_melee_weapon)
	#print("ranged weapon ", current_ranged_weapon)
	
	#TODO 
	#export into own function
	
	if Input.is_action_just_pressed("strafe"):
		is_strafing = not is_strafing
	
	#this is currently the only way to put ranged weapons in the players hand, because there is no 
	#ranged combat state as the result that ranged weapons can be fired off without locking the player into an animation or state
	if putting_ranged_weapon_in_hand_enabled:
		if Input.is_action_just_pressed("ranged_attack") and currently_held_weapon_or_gadget != current_ranged_weapon:
			put_in_hand(current_ranged_weapon)
			
		if Input.is_action_just_pressed("quick_select_up"):
			handle_quick_select("up")
		
		if Input.is_action_just_pressed("quick_select_left"):
			handle_quick_select("left")
		
		if Input.is_action_just_pressed("quick_select_right"):
			handle_quick_select("right")
		
		if Input.is_action_just_pressed("quick_select_down"):
			print(inventory.get_weapons_array_from_quick_select_dir("down"))
			handle_quick_select("down")
			
	if Input.is_action_just_pressed("quick_select_change_panel"):
		inventory.change_quick_select_panel()
	
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


## function for smoothly rotating the player towards a given direction
func _orient_character_to_direction(direction: Vector3, delta: float,rotation_speed:float=_rotation_speed, up_vector: Vector3 = Vector3.UP) -> void:
	var left_axis := up_vector.cross(direction).normalized()
	var rotation_basis := Basis(left_axis, up_vector, direction).orthonormalized().get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)


## function for changing the player physics to that of a ridgidbody (here @PhysicsBody)
## called in StateMachine
func switchToPhysicsBody()-> void:
	_physics_body.set_active(true)

## function to switch the physics back to that of a CharacterBody3D
## called in - @Node StateMachine
func switchToCharacterBody()-> void:
	_physics_body.set_active(false)

## returns the inventory
func get_inventory()->Inventory:
	return inventory

func change_currently_held_weapon_or_gadget_to(weapon_or_gadget_name: StringName)->void:
	var weapon_or_gadget = inventory.get_weapon_or_gadget(weapon_or_gadget_name)
	if weapon_or_gadget is Weapon:
		assign_melee_and_ranged_weapons(weapon_or_gadget)
	put_in_hand(inventory.get_weapon_or_gadget(weapon_or_gadget_name))

#function for putting a weapon in hand - called from player hand
func put_in_hand(weapon_or_gadget: Node)-> void:
	if weapon_or_gadget is Weapon:
		assign_melee_and_ranged_weapons(weapon_or_gadget)
	hand.add_or_replace_item_to_hand(weapon_or_gadget)
	_character_skin.change_weapon(weapon_or_gadget.name, weapon_or_gadget.get_groups())
	currently_held_weapon_or_gadget = weapon_or_gadget

#function for adding the initial weapon loadout to the inventory.
#@param starting_loadout - defined as export PackedStringArray
#@param weapon_path - path to be loaded and instantiated, then added to the inventory
func add_starting_loadout_to_inventory()-> void:
	for weapon_path in starting_loadout:
		var weapon_scene = load(weapon_path).instantiate()
		#weapon_scene = weapon_scene.instantiate()
		if currently_held_weapon_or_gadget == null:
			currently_held_weapon_or_gadget = weapon_scene
		if current_melee_weapon == null and weapon_scene.is_in_group("melee"):
			current_melee_weapon = weapon_scene
		if current_ranged_weapon == null and weapon_scene.is_in_group("ranged"):
			current_ranged_weapon = weapon_scene
		
		inventory.add_weapon(weapon_scene.name, weapon_scene)

func assign_melee_and_ranged_weapons(weapon_scene: Node3D):
	if weapon_scene.is_in_group("melee"):
		current_melee_weapon = weapon_scene
	if  weapon_scene.is_in_group("ranged"):
		current_ranged_weapon = weapon_scene

func handle_quick_select(direction: String):
	var shortcut_array: Array = inventory.get_weapons_array_from_quick_select_dir(direction)
	if shortcut_array.size() == 0:
		printerr("Error: shortcut_array is empty for direction:", direction)
		return

	if currently_held_weapon_or_gadget == shortcut_array[0] and shortcut_array[1] != null:
		currently_held_weapon_or_gadget = shortcut_array[1]
	elif shortcut_array[0] != null:
		currently_held_weapon_or_gadget = shortcut_array[0]
	else:
		printerr("Error: No valid weapon in shortcut_array for direction:", direction)
		return

	put_in_hand(currently_held_weapon_or_gadget)
	emit_signal("weapon_changed", currently_held_weapon_or_gadget.name)
	print("Switched weapon to:", currently_held_weapon_or_gadget.name)

## because the player has buttons for melee and ranged, we need to be able to determine which weapon should be used
func switch_current_weapon_to_melee(melee: bool)-> void:
	if melee and currently_held_weapon_or_gadget != current_melee_weapon:
		put_in_hand(current_melee_weapon)
	if ! melee and currently_held_weapon_or_gadget != current_ranged_weapon:
		put_in_hand(current_ranged_weapon)
