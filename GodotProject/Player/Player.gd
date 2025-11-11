extends CharacterBody3D
class_name Player

## Refactored Player class with cleaner separation of concerns
## Uses manager classes to handle specific functionality

# Signals
signal weapon_changed(weapon_id: StringName)

# Export groups
@export_category("Gameplay")
@export_group("Base Movement")
@export var move_speed: float = 12.0
@export var acceleration: float = 4.0
@export var rotation_speed: float = 12.0
@export var stopping_speed: float = 4.5
@export var jump_apex_gravity: float = -10.0
@export var jump_initial_impulse: float = 12.0

@export_group("Crouching")
@export var crouch_move_speed: float = 6.0
@export var crouch_acceleration: float = 2.0
@export var crouch_rotation_speed: float = 16.0
@export var crouch_jump_initial_impulse: float = 16.0

@export_group("Sliding")
@export var slide_start_threshold: float = 8.0
@export var slide_strength_curve: Curve
@export var slide_strength_curve_factor: float = 1.0
@export var slide_strength_curve_time_factor: float = 1.0

@export_group("Special Moves")
@export var launch_initial_impulse: float = 20.0
@export var grind_end_launch_initial_impulse: float = 18.0

@export_group("Base Loadout")
@export var starting_loadout: PackedStringArray

# Node references
@onready var rotation_root: Node3D = $CharacterRotationRoot
@onready var camera_controller: CameraController = $CameraController
@onready var ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var physics_body: RigidBody3D = $PhysicsBody
@onready var character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var attraction_point: Marker3D = %AttractionPoint
@onready var state_machine = $StateMachine
@onready var inventory: Inventory = $Inventory

# Manager components
@onready var input_handler: PlayerInputHandler = $PlayerInputHandler
@onready var combat_manager: PlayerCombatManager = $PlayerCombatManager
@onready var weapon_manager: ActiveWeaponManager = $ActiveWeaponManager

# Movement state
var move_direction: Vector3 = Vector3.ZERO
var last_strong_direction: Vector3 = Vector3.FORWARD
var gravity: float = -30.0
var ground_height: float = 0.0
var is_on_floor_buffer: bool = false

# Player state flags
var is_crouching: bool = false
var is_sliding: bool = false
var is_grinding: bool = false
var is_grappling: bool = false
var is_monkey_bar: bool = false
var is_ledge_grabbing: bool = false
var is_hanging: bool = false
var is_magnetized: bool = false
var freeze: bool = false

# Combat state (for compatibility with old state machine)
var combo_step: int = 0
var is_melee: bool = false

# Collision state
var crouching_collision_height: float = 0.9
var standing_collision_height: float
var standing_collision_position: Vector3
var crouching_collision_position: Vector3

# Collision recovery
var stuck_timer: float = 0.0
var last_valid_position: Vector3 = Vector3.ZERO
var position_check_timer: float = 0.0

# Parkour components
var can_grind: bool = true
var ledge_ray_vertical: RayCast3D
var ledge_ray_horizontal: RayCast3D

func _ready() -> void:
	print("Player _ready() started")
	_initialize_player()
	print("Player initialized")
	_setup_managers()
	print("Managers setup")
	_connect_signals()
	print("Signals connected")
	_setup_collision()
	print("Collision setup")
	_setup_parkour_components()
	print("Player _ready() completed")

func _initialize_player() -> void:
	add_to_group("players")
	GameHandler.register_player(self)
	
	# Initialize collision measurements
	standing_collision_height = collision_shape.shape.height
	standing_collision_position = Vector3(0, standing_collision_height / 2, 0)
	crouching_collision_position = Vector3(0, crouching_collision_height / 2, 0)

func _setup_managers() -> void:
	# Initialize input handler
	if input_handler:
		input_handler.setup_input()

	# Setup weapon manager references
	if weapon_manager:
		weapon_manager.character_skin = character_skin
		weapon_manager.inventory = inventory
		weapon_manager.initialize_from_loadout(starting_loadout)

	# Setup combat manager references
	if combat_manager:
		combat_manager.weapon_manager = weapon_manager

	# Initialize inventory with gadgets (debug)
	_add_debug_gadgets()

func _connect_signals() -> void:
	# Input handler signals
	if input_handler and input_handler.has_signal("movement_input_changed"):
		input_handler.movement_input_changed.connect(_on_movement_input)
		input_handler.jump_pressed.connect(_on_jump_pressed)
		input_handler.attack_pressed.connect(_on_attack_pressed)
		input_handler.dodge_pressed.connect(_on_dodge_pressed)
		input_handler.crouch_pressed.connect(_on_crouch_pressed)
		input_handler.interact_pressed.connect(_on_interact_pressed)
		input_handler.strafe_toggled.connect(_on_strafe_toggled)
		input_handler.quick_select_pressed.connect(_on_quick_select_pressed)
		input_handler.quick_select_panel_changed.connect(_on_quick_select_panel_changed)
		input_handler.gadget_used.connect(_on_gadget_used)
	
	# Weapon manager signals
	if weapon_manager and weapon_manager.has_signal("weapon_changed"):
		weapon_manager.weapon_changed.connect(_on_weapon_changed)
	
	# Combat manager signals
	if combat_manager and combat_manager.has_signal("attack_started"):
		combat_manager.attack_started.connect(_on_attack_started)
		combat_manager.attack_finished.connect(_on_attack_finished)

func _setup_collision() -> void:
	# Setup collision shape references
	pass

func _setup_parkour_components() -> void:
	# Find and enable ledge detection raycasts
	ledge_ray_vertical = find_child("LedgeRayVertical", true, false)
	ledge_ray_horizontal = find_child("LedgeRayHorizontal", true, false)

	# Enable the raycasts
	if ledge_ray_vertical:
		ledge_ray_vertical.enabled = true
		print("Ledge ray vertical found and enabled")
	else:
		push_warning("LedgeRayVertical not found!")

	if ledge_ray_horizontal:
		ledge_ray_horizontal.enabled = true
		print("Ledge ray horizontal found and enabled")
	else:
		push_warning("LedgeRayHorizontal not found!")

func _add_debug_gadgets() -> void:
	# Temporarily disabled to test what's causing the freeze
	print("Debug gadgets setup completed (skipped for testing)")

func _physics_process(delta: float) -> void:
	_update_ground_height()
	_check_collision_recovery(delta)
	_update_physics(delta)
	_check_debug_toggle()

func _update_ground_height() -> void:
	if ground_shapecast.get_collision_count() > 0:
		for collision_result in ground_shapecast.collision_result:
			ground_height = max(ground_height, collision_result.point.y)
	else:
		ground_height = global_position.y + ground_shapecast.target_position.y
	
	if global_position.y < ground_height:
		ground_height = global_position.y

func _update_physics(delta: float) -> void:
	# This will be handled by the state machine
	# Just ensuring we have the basic physics structure
	pass

func _check_collision_recovery(delta: float) -> void:
	# Check if player is stuck by monitoring velocity and collisions
	position_check_timer += delta

	# Store valid positions periodically
	if position_check_timer >= 0.5:
		if velocity.length() > 0.5 or is_on_floor():
			last_valid_position = global_position
		position_check_timer = 0.0

	# Detect if stuck (has input but very low velocity while colliding)
	var is_trying_to_move = move_direction.length() > 0.1
	var is_barely_moving = velocity.length() < 0.5
	var collision_count = get_slide_collision_count()

	if is_trying_to_move and is_barely_moving and collision_count > 2:
		stuck_timer += delta

		# If stuck for more than 0.3 seconds, try recovery
		if stuck_timer > 0.3:
			_attempt_unstuck_recovery()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0

func _attempt_unstuck_recovery() -> void:
	# Try multiple recovery strategies
	var recovery_directions = [
		Vector3.UP * 0.1,  # Slight upward nudge
		Vector3.LEFT * 0.1,  # Try left
		Vector3.RIGHT * 0.1,  # Try right
		Vector3.FORWARD * 0.1,  # Try forward
		Vector3.BACK * 0.1,  # Try back
	]

	for direction in recovery_directions:
		var test_transform = global_transform
		test_transform.origin += direction

		# Test if this position is valid
		var collision = move_and_collide(direction, true, 0.001, true)
		if not collision:
			# This direction is clear, move there
			global_position += direction
			velocity = Vector3.ZERO  # Reset velocity
			return

	# If all else fails and we have a valid position, teleport back
	if last_valid_position != Vector3.ZERO and global_position.distance_to(last_valid_position) < 5.0:
		global_position = last_valid_position
		velocity = Vector3.ZERO

# Character orientation
func orient_character_to_direction(direction: Vector3, delta: float, custom_rotation_speed: float = -1.0, up_vector: Vector3 = Vector3.UP) -> void:
	var rotation_spd = custom_rotation_speed if custom_rotation_speed > 0 else rotation_speed
	
	var left_axis := up_vector.cross(direction).normalized()
	var rotation_basis := Basis(left_axis, up_vector, direction).orthonormalized().get_rotation_quaternion()
	var model_scale := rotation_root.transform.basis.get_scale()
	
	rotation_root.transform.basis = Basis(
		rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_spd)
	).scaled(model_scale)

# Physics state switching
func switch_to_physics_body() -> void:
	physics_body.set_active(true)

func switch_to_character_body() -> void:
	physics_body.set_active(false)

# Accessors
func get_inventory() -> Inventory:
	return inventory

func get_weapon_manager() -> ActiveWeaponManager:
	return weapon_manager

func get_combat_manager() -> PlayerCombatManager:
	return combat_manager

func get_input_handler() -> PlayerInputHandler:
	return input_handler

func get_current_weapon() -> Weapon:
	return weapon_manager.get_current_weapon() if weapon_manager else null

# State queries
func is_performing_melee() -> bool:
	return combat_manager.is_melee_active() if combat_manager else false

func can_perform_melee() -> bool:
	return combat_manager.can_perform_melee() if combat_manager else false

func is_strafing() -> bool:
	return input_handler.get_strafe_state() if input_handler else false

# Weapon state proxies (for backward compatibility with states)
var putting_ranged_weapon_in_hand_enabled: bool:
	get:
		return weapon_manager.can_switch_to_ranged() if weapon_manager else true
	set(value):
		if weapon_manager:
			weapon_manager.set_ranged_switching_enabled(value)

var currently_held_weapon_or_gadget: Item3D:
	get:
		return weapon_manager.currently_held_weapon_or_gadget if weapon_manager else null

func switch_current_weapon_to_melee(force: bool = false) -> void:
	if weapon_manager:
		weapon_manager.switch_to_melee_weapon()

func switch_current_weapon_to_ranged() -> void:
	if weapon_manager:
		weapon_manager.switch_to_ranged_weapon()

# Legacy property accessors (for backward compatibility with old state files)
var _gravity: float:
	get:
		return gravity

func switchToPhysicsBody() -> void:
	switch_to_physics_body()

func switchToCharacterBody() -> void:
	switch_to_character_body()

# Signal handlers
func _on_movement_input(direction: Vector3) -> void:
	move_direction = direction

func _on_jump_pressed() -> void:
	# Forward to state machine
	if state_machine and state_machine.has_method("handle_jump"):
		state_machine.handle_jump()

func _on_attack_pressed(attack_type: String) -> void:
	if combat_manager:
		combat_manager.try_attack(attack_type)

func _on_dodge_pressed() -> void:
	# Forward to state machine
	if state_machine and state_machine.has_method("handle_dodge"):
		state_machine.handle_dodge()

func _on_crouch_pressed() -> void:
	# Forward to state machine
	if state_machine and state_machine.has_method("handle_crouch"):
		state_machine.handle_crouch()

func _on_interact_pressed() -> void:
	# Handle interaction logic
	pass

func _on_strafe_toggled(enabled: bool) -> void:
	# Strafe state is handled by input handler
	pass

func _on_quick_select_pressed(direction: String) -> void:
	if weapon_manager:
		weapon_manager.handle_quick_select(direction)

func _on_quick_select_panel_changed() -> void:
	if inventory:
		inventory.change_quick_select_panel()

func _on_gadget_used() -> void:
	# Check if we have a grappling hook in inventory
	var grappling_hook = inventory.get_gadget("grappling_hook")
	if grappling_hook and not is_grappling:
		# Transition to grapple state which will activate the hook
		if state_machine:
			state_machine.transition_to("Grapple")

func _on_weapon_changed(weapon_id: StringName) -> void:
	weapon_changed.emit(weapon_id)

func _on_attack_started(attack_type: String) -> void:
	# Transition to appropriate state based on attack type
	if attack_type == "melee":
		if state_machine:
			state_machine.transition_to("Melee")
	# For ranged attacks, we may just fire without changing state
	# depending on your game design

func _on_attack_finished() -> void:
	# Handle attack finish
	pass

# Money collection (keeping existing functionality)
func _on_money_collection_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("money"):
		body.player_detected(self)

func _on_money_collection_range_area_entered(area: Area3D) -> void:
	if area.is_in_group("money"):
		area.player_detected(self)

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("money"):
		body.collect()

func _on_hp_death() -> void:
	get_tree().reload_current_scene()

# Debug visualization toggle
var grapple_debug_enabled: bool = false

func _check_debug_toggle() -> void:
	if Input.is_action_just_pressed("toggle_grapple_debug"):
		grapple_debug_enabled = !grapple_debug_enabled
		_toggle_all_grapple_point_debug(grapple_debug_enabled)
		print("Grapple Debug Visuals: ", "ENABLED" if grapple_debug_enabled else "DISABLED")

func _toggle_all_grapple_point_debug(enabled: bool) -> void:
	var grapple_points = get_tree().get_nodes_in_group("grapplePoint")
	for point in grapple_points:
		if point.has_method("set_debug_enabled"):
			point.set_debug_enabled(enabled)
