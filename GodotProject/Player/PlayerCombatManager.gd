extends Node
class_name PlayerCombatManager

## Manages player combat state and actions
## Handles melee combos, attack timing, and combat-related state

signal attack_started(attack_type: String)
signal attack_finished()
signal combo_step_changed(step: int)

@export var attack_timer: Timer
@export var combo_timer: Timer
@export var weapon_manager: ActiveWeaponManager

# Combat configuration
@export var attack_impulse: float = 100.0
@export var max_throwback_force: float = 15.0
@export var parry_window: float = 0.1
@export var block_time: float = 2.0

# Combat state
var combo_step: int = 0
var can_melee: bool = true  # Start enabled so player can attack
var is_melee: bool = false
var attack_step_finished: bool = true

func _ready() -> void:
	if not attack_timer:
		attack_timer = get_node("../AttackTimer") if has_node("../AttackTimer") else null
	if not combo_timer:
		combo_timer = get_node("../ComboTimer") if has_node("../ComboTimer") else null
	if not weapon_manager:
		weapon_manager = get_node("../ActiveWeaponManager") if has_node("../ActiveWeaponManager") else null
	
	_setup_timers()

func _setup_timers() -> void:
	if attack_timer:
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	if combo_timer:
		combo_timer.timeout.connect(_on_combo_timer_timeout)

## Attempt to perform an attack
func try_attack(attack_type: String) -> bool:
	if attack_type == "melee":
		return _try_melee_attack()
	elif attack_type == "ranged":
		return _try_ranged_attack()
	return false

## Try to perform a melee attack
func _try_melee_attack() -> bool:
	if not can_melee or is_melee or not attack_step_finished:
		return false
	
	if not weapon_manager or not weapon_manager.get_melee_weapon():
		return false
	
	# Switch to melee weapon if not already equipped
	weapon_manager.switch_to_melee_weapon()
	
	_start_melee_attack()
	return true

## Try to perform a ranged attack
func _try_ranged_attack() -> bool:
	if not weapon_manager or not weapon_manager.get_ranged_weapon():
		return false
	
	# Switch to ranged weapon if enabled and not already equipped
	if weapon_manager.can_switch_to_ranged():
		weapon_manager.switch_to_ranged_weapon()
	
	_start_ranged_attack()
	return true

## Start a melee attack sequence
func _start_melee_attack() -> void:
	is_melee = true
	attack_step_finished = false
	combo_step += 1
	
	attack_started.emit("melee")
	combo_step_changed.emit(combo_step)
	
	# Start attack timer
	if attack_timer:
		attack_timer.start()

## Start a ranged attack
func _start_ranged_attack() -> void:
	attack_started.emit("ranged")
	
	var ranged_weapon = weapon_manager.get_ranged_weapon()
	if ranged_weapon and ranged_weapon.has_method("fire"):
		ranged_weapon.fire()

## Reset combat state
func reset_combat_state() -> void:
	combo_step = 0
	can_melee = true
	is_melee = false
	attack_step_finished = true
	combo_step_changed.emit(combo_step)

## Enable/disable melee attacks
func set_melee_enabled(enabled: bool) -> void:
	can_melee = enabled

## Check if currently performing melee
func is_melee_active() -> bool:
	return is_melee

## Check if can perform melee
func can_perform_melee() -> bool:
	return can_melee and attack_step_finished

## Get current combo step
func get_combo_step() -> int:
	return combo_step

## Handle taking damage/knockback
func take_damage(damage_amount: float, impact_point: Vector3) -> void:
	# Calculate knockback direction
	var player = get_parent() as CharacterBody3D
	if not player:
		return
	
	var knockback_direction = (player.global_position - impact_point).normalized()
	var knockback_force = min(damage_amount * 2.0, max_throwback_force)
	
	# Apply knockback to player velocity
	player.velocity += knockback_direction * knockback_force

# Timer callbacks
func _on_attack_timer_timeout() -> void:
	attack_step_finished = true
	is_melee = false
	attack_finished.emit()
	
	# Start combo timer for combo window
	if combo_timer:
		combo_timer.start()

func _on_combo_timer_timeout() -> void:
	# Reset combo if no new attack within combo window
	combo_step = 0
	combo_step_changed.emit(combo_step)
