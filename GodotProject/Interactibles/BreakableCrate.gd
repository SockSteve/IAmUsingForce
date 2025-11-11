extends RigidBody3D
class_name BreakableCrate

## Breakable crate that drops money when destroyed
##
## Features:
## - Physics-based with automatic freezing when settled
## - Visibility culling for performance (frozen when off-screen)
## - Money drops on destruction
## - Camera shake on break
## - Can be destroyed by bullets or melee

signal broken

@export_group("Crate Properties")
## Health of the crate
@export var max_health: int = 30

## Current health
var current_health: int = 30

@export_group("Loot")
## Amount of money to drop
@export var money_amount: int = 20

## Scatter radius for money drops
@export_range(0.0, 3.0, 0.1) var money_scatter_radius: float = 1.0

@export_group("Physics")
## Time before crate freezes if not moving (seconds)
@export var freeze_timeout: float = 2.0

## Velocity threshold to consider "not moving"
@export_range(0.0, 1.0, 0.01) var freeze_velocity_threshold: float = 0.1

## Enable physics when on screen, freeze when off screen
@export var freeze_when_off_screen: bool = true

@export_group("Visual")
## Mesh for the crate (optional, will create default box if not set)
@export var crate_mesh: Mesh

## Material for the crate
@export var crate_material: Material

@export_group("Camera Shake")
## Enable camera shake when destroyed
@export var enable_shake: bool = true

## Shake intensity (Light=0, Medium=1, Heavy=2)
@export_enum("Light", "Medium", "Heavy") var shake_intensity: int = 1

@export_group("Debris")
## Enable debris particles on destruction
@export var spawn_debris: bool = true

## Debris piece count
@export_range(3, 20) var debris_count: int = 8

# Node references
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var visibility_notifier: VisibleOnScreenNotifier3D
var camera_shake_emitter: CameraShakeEmitter

# State tracking
var is_frozen: bool = false
var freeze_timer: float = 0.0
var is_visible_on_screen: bool = false

func _ready() -> void:
	_setup_nodes()
	_setup_physics()
	_setup_collision_layers()
	current_health = max_health

	# Start monitoring for freeze
	set_physics_process(true)

func _setup_nodes() -> void:
	"""Creates necessary child nodes"""
	# Create mesh instance
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	add_child(mesh_instance)

	if crate_mesh:
		mesh_instance.mesh = crate_mesh
	else:
		# Default crate box
		var box = BoxMesh.new()
		box.size = Vector3(1, 1, 1)
		mesh_instance.mesh = box

	if crate_material:
		mesh_instance.material_override = crate_material

	# Create collision shape
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision_shape.shape = box_shape
	add_child(collision_shape)

	# Create visibility notifier
	visibility_notifier = VisibleOnScreenNotifier3D.new()
	visibility_notifier.name = "VisibleOnScreenNotifier3D"
	visibility_notifier.aabb = AABB(Vector3(-0.5, -0.5, -0.5), Vector3(1, 1, 1))
	add_child(visibility_notifier)

	# Connect visibility signals
	visibility_notifier.screen_entered.connect(_on_screen_entered)
	visibility_notifier.screen_exited.connect(_on_screen_exited)

	# Create camera shake emitter if enabled
	if enable_shake:
		camera_shake_emitter = CameraShakeEmitter.new()
		camera_shake_emitter.name = "CameraShakeEmitter"
		_configure_shake()
		add_child(camera_shake_emitter)

func _setup_physics() -> void:
	"""Configure RigidBody3D physics properties"""
	mass = 5.0
	gravity_scale = 1.0
	continuous_cd = true  # Better collision detection
	can_sleep = true
	lock_rotation = false

func _setup_collision_layers() -> void:
	"""Setup collision layers for proper interaction"""
	# Layer 4 (Destructible) as per CLAUDE.md
	collision_layer = 1 << 3  # Layer 4
	# Collide with: Floor (6), Walls (5), Player bullets (9)
	collision_mask = (1 << 5) | (1 << 4) | (1 << 8)

func _configure_shake() -> void:
	"""Configures shake based on intensity preset"""
	if not camera_shake_emitter:
		return

	match shake_intensity:
		0:  # Light
			camera_shake_emitter.shake_amplitude = 0.15
			camera_shake_emitter.shake_duration = 0.2
		1:  # Medium
			camera_shake_emitter.shake_amplitude = 0.25
			camera_shake_emitter.shake_duration = 0.3
		2:  # Heavy
			camera_shake_emitter.shake_amplitude = 0.4
			camera_shake_emitter.shake_duration = 0.4

func _physics_process(delta: float) -> void:
	# Handle visibility-based freezing
	if freeze_when_off_screen and not is_visible_on_screen:
		if not is_frozen:
			freeze = true
			is_frozen = true
		return

	# Check if crate should freeze due to inactivity
	if not freeze and linear_velocity.length() < freeze_velocity_threshold:
		freeze_timer += delta
		if freeze_timer >= freeze_timeout:
			freeze = true
			is_frozen = true
			set_physics_process(false)  # Stop checking once frozen
	else:
		freeze_timer = 0.0

func _on_screen_entered() -> void:
	"""Called when crate becomes visible on screen"""
	is_visible_on_screen = true
	if is_frozen and freeze_when_off_screen:
		freeze = false
		is_frozen = false
		set_physics_process(true)

func _on_screen_exited() -> void:
	"""Called when crate goes off screen"""
	is_visible_on_screen = false

## Called when a bullet hits this crate
func on_bullet_hit(bullet: Node3D, hit_position: Vector3, hit_normal: Vector3) -> void:
	print("BreakableCrate hit at: ", hit_position)

	# Wake up if frozen
	if is_frozen:
		freeze = false
		is_frozen = false
		freeze_timer = 0.0
		set_physics_process(true)

	# Apply damage
	take_damage(10)

	# Apply impact force
	var impact_force = hit_normal * -5.0
	apply_impulse(impact_force, hit_position - global_position)

## Take damage and break if health depleted
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Crate health: ", current_health, "/", max_health)

	# Flash effect
	_flash_mesh()

	if current_health <= 0:
		break_crate()

func _flash_mesh() -> void:
	"""Brief visual feedback when hit"""
	if not mesh_instance:
		return

	var mat = mesh_instance.get_active_material(0)
	if mat and mat is StandardMaterial3D:
		var original_color = mat.albedo_color
		var tween = create_tween()
		tween.tween_property(mat, "albedo_color", Color(1, 0.8, 0.6), 0.1)
		tween.tween_property(mat, "albedo_color", original_color, 0.1)

## Break the crate and spawn loot
func break_crate() -> void:
	print("Crate broken!")
	broken.emit()

	# Emit camera shake
	if enable_shake and camera_shake_emitter:
		camera_shake_emitter.emit_shake()

	# Spawn money
	_spawn_money()

	# Spawn debris
	if spawn_debris:
		_spawn_debris()

	# Remove crate
	queue_free()

func _spawn_money() -> void:
	"""Spawns money drops scattered around the crate"""
	if money_amount <= 0:
		return

	const MONEY_SCENE = "res://Interactibles/Money/Money.tscn"
	const CHUNKS = [
		{ "value": 100, "type": "gold", "big": false },
		{ "value": 50,  "type": "silver", "big": true },
		{ "value": 10,  "type": "silver", "big": false }
	]

	var remaining = money_amount
	var spawn_parent = get_parent()

	for chunk in CHUNKS:
		var count = remaining / chunk["value"]
		remaining %= chunk["value"]

		for i in range(count):
			var money_instance = load(MONEY_SCENE).instantiate() as Money
			money_instance.value = chunk["value"]
			money_instance.money_type = chunk["type"]
			money_instance.big = chunk["big"]

			# Spawn with random scatter
			var scatter_offset = Vector3(
				randf_range(-money_scatter_radius, money_scatter_radius),
				randf_range(0.5, 1.5),
				randf_range(-money_scatter_radius, money_scatter_radius)
			)

			spawn_parent.add_child(money_instance)
			money_instance.global_position = global_position + scatter_offset
			money_instance.apply_visuals()

func _spawn_debris() -> void:
	"""Spawns debris particles when broken"""
	# Simple debris using small rigid bodies
	for i in range(debris_count):
		var debris = RigidBody3D.new()

		# Small cube mesh
		var mesh_inst = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.2, 0.2, 0.2)
		mesh_inst.mesh = box

		# Copy material from crate
		if crate_material:
			mesh_inst.material_override = crate_material

		debris.add_child(mesh_inst)

		# Add collision
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.2, 0.2, 0.2)
		col.shape = shape
		debris.add_child(col)

		# Configure physics
		debris.mass = 0.5
		debris.gravity_scale = 1.0

		# Add to scene
		get_parent().add_child(debris)
		debris.global_position = global_position + Vector3(
			randf_range(-0.3, 0.3),
			randf_range(0, 0.5),
			randf_range(-0.3, 0.3)
		)

		# Apply random impulse
		debris.apply_impulse(Vector3(
			randf_range(-3, 3),
			randf_range(2, 5),
			randf_range(-3, 3)
		))

		# Auto-delete after 5 seconds
		var timer = get_tree().create_timer(5.0)
		timer.timeout.connect(func():
			if is_instance_valid(debris):
				debris.queue_free()
		)

## Force wake up the crate (useful for debugging or triggering)
func wake_up() -> void:
	if is_frozen:
		freeze = false
		is_frozen = false
		freeze_timer = 0.0
		set_physics_process(true)
