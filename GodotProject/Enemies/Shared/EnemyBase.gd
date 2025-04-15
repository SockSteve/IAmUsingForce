class_name Enemy
extends CharacterBody3D

@export var ai_config: EnemyAIConfig
@export var stagger_config: StaggerConfig
@export var nav_agent: NavigationAgent3D
@export var detection_area: Area3D
@export var animation_player: AnimationPlayer
@export var hp_component: Hp
@export var hurtbox: Hurtbox

# Rotation and movement parameters
@export_group("movements")
@export var rotation_speed: float = 8.0
@export var acceleration: float = 10.0
@export_group("attack behaviour")
@export var has_melee_attack: bool = true  # Default to melee-only enemies
@export var has_ranged_attack: bool = false
@export var melee_range: float = 2.0  # Fallback value if not in ai_config
@export var ranged_range: float = 10.0  # Fallback value if not in ai_config
@export var melee_cooldown: float = 1.0  # Fallback value if not in ai_config
@export var ranged_cooldown: float = 2.0  # Fallback value if not in ai_config
@export var max_burst_count: int = 1  # How many shots in a burst
@export var burst_delay: float = 0.3  # Delay between shots in a burst

# Stagger parameters
var should_stop_movement: bool = false
var is_staggered: bool = false
var stagger_timer: float = 0.0
var stagger_immunity_timer: float = 0.0
var stagger_direction: Vector3 = Vector3.ZERO
var hit_counter: int = 0
var hit_counter_reset_timer: float = 0.0
var last_damage_amount: float = 0.0

# For phase tracking
var triggered_phases: Array[float] = []

# Standard signals
signal target_changed(target)

# Movement related variables
var origin: Vector3 = Vector3.ZERO
var detected_players: Array[Node3D] = []
var current_target: Node3D = null
var is_dead: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if animation_player:
		print("Animation player found")
		print("Available animations: ", animation_player.get_animation_list())
	else:
		print("No animation player assigned!")
	origin = global_position
	
	# Create default stagger config if none provided
	if not stagger_config:
		stagger_config = StaggerConfig.new()
	
	# Setup navigation agent avoidance
	nav_agent.avoidance_enabled = ai_config.avoid_enemies
	nav_agent.radius = ai_config.avoid_radius
	nav_agent.max_neighbors = 10
	nav_agent.time_horizon = 1.0
	nav_agent.max_speed = ai_config.move_speed
	
	# Connect detection area signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	## Setup detection area size based on config
	#var collision_shape = detection_area.get_node_or_null("CollisionShape3D")
	#if collision_shape and collision_shape.shape is SphereShape3D:
		#collision_shape.shape.radius = ai_config.detection_radius
	
	# Connect to HP component for damage and death
	if hp_component:
		hp_component.hp_chaged.connect(_on_hp_changed)
		hp_component.death.connect(_on_death)
		hp_component.stagger.connect(_on_stagger)

func _physics_process(delta: float) -> void:
	# Apply gravity only once, and only if not on floor
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Update timers
	if is_staggered:
		stagger_timer += delta
		if stagger_timer >= stagger_config.stagger_duration:
			is_staggered = false
			stagger_timer = 0.0
			
			# Resume normal animations after stagger
			var state_machine = get_node_or_null("StateMachine")
			if state_machine and state_machine is EnemyStateMachine:
				state_machine.resume_from_stagger()
	
	# Update stagger immunity timer
	if stagger_immunity_timer > 0:
		stagger_immunity_timer -= delta
		if stagger_immunity_timer < 0:
			stagger_immunity_timer = 0
	
	# Update hit counter reset timer
	if hit_counter > 0 and stagger_config.condition == StaggerConfig.StaggerCondition.HIT_COUNT:
		hit_counter_reset_timer += delta
		if hit_counter_reset_timer >= stagger_config.reset_hit_count_after:
			hit_counter = 0
			hit_counter_reset_timer = 0.0
	
	if should_stop_movement and not is_staggered:
		velocity.x = lerp(velocity.x, 0.0, 0.3)  # Smooth stop
		velocity.z = lerp(velocity.z, 0.0, 0.3)
	
	# Always apply movement at the end, regardless of stagger state
	# This ensures gravity is always applied
	move_and_slide()

func should_stagger(damage_amount: float) -> bool:
	# If stagger is disabled or we're in immunity period, don't stagger
	if not stagger_config.enabled or is_staggered or stagger_immunity_timer > 0:
		return false
	
	# Store damage amount for potential use
	last_damage_amount = damage_amount
	
	# Check stagger condition
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
				
				# Check each phase
				for phase in stagger_config.health_phases:
					# If we've crossed a phase threshold and haven't triggered it yet
					if current_health_percent <= phase and not triggered_phases.has(phase):
						# Mark this phase as triggered
						triggered_phases.append(phase)
						return true
			return false
	
	return false

func move_to_position(target_pos: Vector3, delta: float) -> void:
	if is_dead or is_staggered:
		return
	
	# Set the target position
	nav_agent.target_position = target_pos
	
	# If navigation is still calculating the path or we've reached the destination
	if nav_agent.is_navigation_finished():
		return
	
	# Get the next position from the navigation agent
	var next_pos = nav_agent.get_next_path_position()
	
	# Calculate direction to the next position
	var direction = (next_pos - global_position)
	direction.y = 0.0  # Keep movement on the horizontal plane
	direction = direction.normalized()
	
	# Apply smooth rotation towards the movement direction
	if direction != Vector3.ZERO:
		smooth_look_at(global_position + direction, delta)
	
	# Calculate target velocity with acceleration
	var target_velocity = direction * ai_config.move_speed
	
	# Smoothly accelerate towards target velocity
	velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	
	# Move the character
	move_and_slide()

func smooth_look_at(target: Vector3, delta: float, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = true) -> void:
	var direction = (target - global_position).normalized()
	direction.y = 0.0  # Ensure rotation only on Y-axis
	
	if direction == Vector3.ZERO:
		return
	
	# Get current and target rotations as quaternions
	if use_model_front:
		direction *= -1
	var current_rotation = Quaternion(global_transform.basis)
	var target_rotation = Quaternion(Basis.looking_at(direction, up))
	
	# Interpolate between the current and target rotation
	var new_rotation = current_rotation.slerp(target_rotation, rotation_speed * delta)
	
	# Apply the interpolated rotation
	global_transform.basis = Basis(new_rotation)

func get_target_player() -> Node3D:
	if detected_players.is_empty():
		return null
	
	match ai_config.target_priority:
		EnemyAIConfig.TargetPriority.FIRST_DETECTED:
			return detected_players[0]
		EnemyAIConfig.TargetPriority.CLOSEST:
			var closest_player = null
			var closest_distance = INF
			
			for player in detected_players:
				var distance = global_position.distance_to(player.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_player = player
			
			return closest_player
	
	return null

# Melee attack function
func melee_attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("melee_attack"):
		animation_player.play("melee_attack")
	else:
		# Fallback to generic attack animation
		attack()

# Ranged attack function
func ranged_attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("ranged_attack"):
		animation_player.play("ranged_attack")
	else:
		# Fallback to generic attack animation
		attack()

# Enhanced target range check
func is_target_in_melee_range() -> bool:
	if current_target:
		var melee_attack_range = ai_config.melee_range if "melee_range" in ai_config else melee_range
		return global_position.distance_to(current_target.global_position) <= melee_attack_range
	return false

func is_target_in_ranged_range() -> bool:
	if current_target:
		var ranged_attack_range = ai_config.ranged_range if "ranged_range" in ai_config else ranged_range
		return global_position.distance_to(current_target.global_position) <= ranged_attack_range
	return false

func is_target_in_attack_range() -> bool:
	if current_target:
		return global_position.distance_to(current_target.global_position) <= ai_config.attack_range
	return false

func attack() -> void:
	if is_dead or is_staggered:
		return
	
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")

func apply_stagger(impact_point: Vector3, force: float) -> void:
	if is_dead:
		return
	
	is_staggered = true
	stagger_timer = 0.0
	stagger_immunity_timer = stagger_config.immunity_after_stagger
	
	# Reset hit counter after stagger is applied
	if stagger_config.condition == StaggerConfig.StaggerCondition.HIT_COUNT:
		hit_counter = 0
	
	# Calculate stagger direction (away from impact)
	stagger_direction = (global_position - impact_point).normalized()
	stagger_direction.y = 0.0  # Keep on horizontal plane
	
	# Apply the stagger force as velocity
	velocity = stagger_direction * force
	
	# Play stagger animation if available
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

func _on_detection_area_body_entered(body: Node3D) -> void:
	if is_dead:
		return
	
	if body.is_in_group("player") and not detected_players.has(body):
		detected_players.append(body)
		
		# Update current target based on priority
		var new_target = get_target_player()
		var old_target = current_target
		current_target = new_target
		
		if old_target != current_target:
			target_changed.emit(current_target)
		
		# Notify state machine
		var state_machine = get_node_or_null("StateMachine")
		if state_machine and state_machine is EnemyStateMachine:
			state_machine.on_player_detected(new_target)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if is_dead:
		return
	
	if detected_players.has(body):
		detected_players.erase(body)
		
		var old_target = current_target
		
		# Update current target or set to null if no players detected
		current_target = get_target_player()
		
		if old_target != current_target:
			target_changed.emit(current_target)
		
		# Notify state machine if the tracked target was lost
		if old_target == body:
			var state_machine = get_node_or_null("StateMachine")
			if state_machine and state_machine is EnemyStateMachine:
				state_machine.on_player_lost(body)

func _on_hp_changed(source, is_dead = false) -> void:
	if is_dead:
		return
	
	# Extract damage amount from HP component if possible
	if hp_component and hp_component.current_health >= 0:
		# Calculate approximate damage based on health change
		# This assumes hp_changed is called right after the health is reduced
		last_damage_amount = hp_component.max_health - hp_component.current_health
	
	# For health phases, we need to check here too in case hp_changed is called
	# without going through take_damage (e.g., healing, direct health changes)
	if stagger_config.condition == StaggerConfig.StaggerCondition.HEALTH_PHASES and hp_component:
		var current_health_percent = (hp_component.current_health / float(hp_component.max_health)) * 100.0
		
		# Update triggered phases (e.g., if health increases back above a threshold)
		var indices_to_remove = []
		for i in range(triggered_phases.size()):
			var phase = triggered_phases[i]
			if current_health_percent > phase:
				indices_to_remove.append(i)
		
		# Remove from highest index to lowest to avoid shifting issues
		indices_to_remove.sort()
		indices_to_remove.reverse()
		for index in indices_to_remove:
			triggered_phases.remove_at(index)
	
	# If we have a source and it's a player, focus on that player
	if source and source.get_parent() and source.get_parent().is_in_group("players"):
		var player = source.get_parent()
		
		# If the player isn't already our target, switch to it
		if current_target != player and detected_players.has(player):
			var old_target = current_target
			current_target = player
			
			if old_target != current_target:
				target_changed.emit(current_target)
			
			# Notify state machine
			var state_machine = get_node_or_null("StateMachine")
			if state_machine and state_machine is EnemyStateMachine:
				state_machine.on_target_changed(player)

func _on_stagger(impact_point: Vector3, force: float) -> void:
	# Check if we should stagger based on our config
	if should_stagger(last_damage_amount):
		apply_stagger(impact_point, force)
		
		# Notify state machine
		var state_machine = get_node_or_null("StateMachine")
		if state_machine and state_machine is EnemyStateMachine:
			state_machine.on_enemy_staggered()

func _on_death() -> void:
	is_dead = true
	
	# Play death animation
	play_animation("death")
	
	# Disable collision and navigation
	var collision = get_node_or_null("CollisionShape3D")
	if collision:
		collision.disabled = true
	
	# Disable detection
	detection_area.monitoring = false
	detection_area.monitorable = false
	
	# Stop movement
	velocity = Vector3.ZERO
	
	# Notify state machine
	var state_machine = get_node_or_null("StateMachine")
	if state_machine and state_machine is EnemyStateMachine:
		state_machine.on_enemy_death()
	
	# Queue free after animation finishes
	if animation_player:
		await animation_player.animation_finished
	
	queue_free()

# Reset phases on respawn or on new enemy instance
func reset_health_phases() -> void:
	triggered_phases.clear()
