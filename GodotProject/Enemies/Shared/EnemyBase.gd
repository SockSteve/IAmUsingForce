# Enemy.gd - Clean base class using distance/LOS detection
class_name Enemy
extends CharacterBody3D

@export var ai_config: EnemyAIConfig #= EnemyAIConfig.new()
@export var stagger_config: StaggerConfig #= StaggerConfig.new()
@export var nav_agent: NavigationAgent3D
@export var animation_player: AnimationPlayer
@export var screen_enabler: VisibleOnScreenEnabler3D
@export var hp_component: Hp
@export var hurtbox: Hurtbox

# Stagger parameters
var should_stop_movement: bool = false
var is_staggered: bool = false
var stagger_timer: float = 0.0
var stagger_immunity_timer: float = 0.0
var stagger_direction: Vector3 = Vector3.ZERO
var hit_counter: int = 0
var hit_counter_reset_timer: float = 0.0
var last_damage_amount: float = 0.0
var triggered_phases: Array[float] = []

# Standard signals
signal target_changed(target)

# Core state variables
var is_on_screen: bool = true
var current_target: Node3D = null
var last_distance_to_player: float = INF
var can_see_target: bool = false

# Basic variables
var origin: Vector3 = Vector3.ZERO
var is_dead: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemy")
	GameHandler.register_enemy(self)
	
	if animation_player:
		print("Animation player found")
		print("Available animations: ", animation_player.get_animation_list())
	else:
		print("No animation player assigned!")
	
	origin = global_position
	

	# Create default AI config if none provided
	if not ai_config:
		ai_config = EnemyAIConfig.new()
	
	# Create default stagger config if none provided
	if not stagger_config:
		stagger_config = StaggerConfig.new()
	
	# Setup navigation (check if nav_agent exists)
	if nav_agent:
		nav_agent.avoidance_enabled = ai_config.avoid_enemies
		nav_agent.radius = ai_config.avoid_radius
		nav_agent.max_neighbors = 10
		nav_agent.time_horizon = 1.0
		nav_agent.max_speed = ai_config.move_speed
	
	# Connect HP component
	if hp_component:
		hp_component.hp_chaged.connect(_on_hp_changed)
		hp_component.death.connect(_on_death)
		hp_component.stagger.connect(_on_stagger)
	
	# Screen enabler
	screen_enabler.screen_entered.connect(_on_screen_entered)
	screen_enabler.screen_exited.connect(_on_screen_exited)

func _on_screen_entered():
	is_on_screen = true
	set_physics_process(true)

func _on_screen_exited():
	is_on_screen = false
	set_physics_process(false)

# Called by GameHandler with distance/LOS detection results
func _on_distance_update(closest_player: Node3D):
	var old_target = current_target
	current_target = closest_player
	
	if old_target != current_target:
		target_changed.emit(current_target)
		
		# Notify state machine of target change
		var state_machine = get_node_or_null("StateMachine")
		if state_machine and state_machine is EnemyStateMachine:
			if current_target:
				state_machine.on_player_detected(current_target)
			else:
				state_machine.on_player_lost(old_target)
	
	# Request line-of-sight check if target in range and on screen
	if current_target and is_on_screen and ai_config and last_distance_to_player <= ai_config.detection_radius:
		GameHandler.request_los_check(self)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Update stagger timers
	_update_stagger_timers(delta)
	
	# Handle movement stopping
	if should_stop_movement and not is_staggered:
		velocity.x = lerp(velocity.x, 0.0, 0.3)
		velocity.z = lerp(velocity.z, 0.0, 0.3)
	
	move_and_slide()

func _update_stagger_timers(delta: float):
	if is_staggered:
		stagger_timer += delta
		if stagger_timer >= stagger_config.stagger_duration:
			is_staggered = false
			stagger_timer = 0.0
			
			var state_machine = get_node_or_null("StateMachine")
			if state_machine and state_machine is EnemyStateMachine:
				state_machine.resume_from_stagger()
	
	if stagger_immunity_timer > 0:
		stagger_immunity_timer -= delta
		if stagger_immunity_timer < 0:
			stagger_immunity_timer = 0
	
	if hit_counter > 0 and stagger_config.condition == StaggerConfig.StaggerCondition.HIT_COUNT:
		hit_counter_reset_timer += delta
		if hit_counter_reset_timer >= stagger_config.reset_hit_count_after:
			hit_counter = 0
			hit_counter_reset_timer = 0.0

func move_to_position(target_pos: Vector3, delta: float) -> void:
	if is_dead or is_staggered or not nav_agent or not ai_config:
		return
	
	nav_agent.target_position = target_pos
	
	if nav_agent.is_navigation_finished():
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position)
	direction.y = 0.0
	direction = direction.normalized()
	
	if direction != Vector3.ZERO:
		smooth_look_at(global_position + direction, delta)
	
	var target_velocity = direction * ai_config.move_speed
	velocity.x = lerp(velocity.x, target_velocity.x, ai_config.acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, ai_config.acceleration * delta)

func smooth_look_at(target: Vector3, delta: float, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = true) -> void:
	var direction = (target - global_position).normalized()
	direction.y = 0.0
	
	if direction == Vector3.ZERO:
		return
	
	if use_model_front:
		direction *= -1
	
	var current_rotation = Quaternion(global_transform.basis)
	var target_rotation = Quaternion(Basis.looking_at(direction, up))
	var new_rotation = current_rotation.slerp(target_rotation, ai_config.rotation_speed * delta)
	
	global_transform.basis = Basis(new_rotation)

# Attack methods based on AI config
func melee_attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("melee_attack"):
		animation_player.play("melee_attack")
	else:
		attack()

func ranged_attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("ranged_attack"):
		animation_player.play("ranged_attack")
	else:
		attack()

func attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")

# Range checks using new AI config structure
func is_target_in_melee_range() -> bool:
	if current_target:
		return global_position.distance_to(current_target.global_position) <= ai_config.attack_melee_range
	return false

func is_target_in_ranged_range() -> bool:
	if current_target:
		return global_position.distance_to(current_target.global_position) <= ai_config.attack_ranged_range
	return false

func can_use_melee_attack() -> bool:
	return ai_config.attack_type == EnemyAIConfig.AttackType.MELEE or ai_config.attack_type == EnemyAIConfig.AttackType.BOTH

func can_use_ranged_attack() -> bool:
	return ai_config.attack_type == EnemyAIConfig.AttackType.RANGED or ai_config.attack_type == EnemyAIConfig.AttackType.BOTH

# Line of sight check - called by GameHandler
func _perform_los_check():
	if not current_target:
		can_see_target = false
		return
	
	var start_pos = global_position + Vector3.UP * 1.5
	var end_pos = current_target.global_position + Vector3.UP * 1.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.collision_mask = 1
	query.collide_with_areas = false
	
	var result = space_state.intersect_ray(query)
	can_see_target = result.is_empty() or result.collider.is_in_group("player")

# Stagger system (keeping your exact implementation)
func should_stagger(damage_amount: float) -> bool:
	if not stagger_config.enabled or is_staggered or stagger_immunity_timer > 0:
		return false
	
	last_damage_amount = damage_amount
	
	match stagger_config.condition:
		StaggerConfig.StaggerCondition.NEVER:
			return false
		StaggerConfig.StaggerCondition.ALWAYS:
			return true
		StaggerConfig.StaggerCondition.DAMAGE_THRESHOLD:
			return damage_amount >= stagger_config.damage_threshold
		StaggerConfig.StaggerCondition.HEALTH_PERCENT:
			if hp_component:
				var health_percent = (hp_component.current_health / float(hp_component.max_health)) * 100.0
				return health_percent <= stagger_config.health_percent_threshold
			return false
		StaggerConfig.StaggerCondition.HIT_COUNT:
			hit_counter += 1
			hit_counter_reset_timer = 0.0
			return hit_counter >= stagger_config.hit_count_threshold
		StaggerConfig.StaggerCondition.HEALTH_PHASES:
			if hp_component:
				var current_health_percent = (hp_component.current_health / float(hp_component.max_health)) * 100.0
				
				for phase in stagger_config.health_phases:
					if current_health_percent <= phase and not triggered_phases.has(phase):
						triggered_phases.append(phase)
						return true
			return false
	
	return false

func apply_stagger(impact_point: Vector3, force: float) -> void:
	if is_dead:
		return
	
	is_staggered = true
	stagger_timer = 0.0
	stagger_immunity_timer = stagger_config.immunity_after_stagger
	
	if stagger_config.condition == StaggerConfig.StaggerCondition.HIT_COUNT:
		hit_counter = 0
	
	stagger_direction = (global_position - impact_point).normalized()
	stagger_direction.y = 0.0
	
	velocity = stagger_direction * force
	
	if animation_player and animation_player.has_animation("stagger"):
		animation_player.play("stagger")
	elif animation_player and animation_player.has_animation("damage"):
		animation_player.play("damage")

func play_animation(anim_name: String) -> void:
	if is_dead and anim_name != "death":
		return
	
	if is_staggered and anim_name != "stagger" and anim_name != "damage":
		return
	
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

# Signal handlers
func _on_hp_changed(source, is_dead_param = false) -> void:
	if is_dead:
		return
	
	if hp_component and hp_component.current_health >= 0:
		last_damage_amount = hp_component.max_health - hp_component.current_health
	
	# Handle health phases for stagger
	if stagger_config.condition == StaggerConfig.StaggerCondition.HEALTH_PHASES and hp_component:
		var current_health_percent = (hp_component.current_health / float(hp_component.max_health)) * 100.0
		
		var indices_to_remove = []
		for i in range(triggered_phases.size()):
			var phase = triggered_phases[i]
			if current_health_percent > phase:
				indices_to_remove.append(i)
		
		indices_to_remove.sort()
		indices_to_remove.reverse()
		for index in indices_to_remove:
			triggered_phases.remove_at(index)
	
	# Focus on attacking player if damaged by one (will be handled by GameHandler distance detection)
	if source and source.get_parent() and source.get_parent().is_in_group("players"):
		var player = source.get_parent()
		print("Enemy was damaged by player: ", player.name)

func _on_stagger(impact_point: Vector3, force: float) -> void:
	if should_stagger(last_damage_amount):
		apply_stagger(impact_point, force)
		
		var state_machine = get_node_or_null("StateMachine")
		if state_machine and state_machine is EnemyStateMachine:
			state_machine.on_enemy_staggered()

func _on_death() -> void:
	is_dead = true
	
	play_animation("death")
	
	var collision = get_node_or_null("CollisionShape3D")
	if collision:
		collision.disabled = true
	
	velocity = Vector3.ZERO
	
	var state_machine = get_node_or_null("StateMachine")
	if state_machine and state_machine is EnemyStateMachine:
		state_machine.on_enemy_death()
	
	if animation_player:
		await animation_player.animation_finished
	
	queue_free()

func reset_health_phases() -> void:
	triggered_phases.clear()
