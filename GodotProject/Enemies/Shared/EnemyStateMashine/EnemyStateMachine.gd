class_name EnemyStateMachine
extends Node

@export var initial_state: NodePath
@export var enemy: Enemy

var current_state: EnemyState = null
var previous_state: EnemyState = null
var states: Dictionary = {}
var stagger_interrupted: bool = false

func _ready() -> void:
	for child in get_children():
		if child is EnemyState:
			states[child.name] = child
			child.enemy = enemy
			child.state_machine = self
	
	if initial_state:
		change_state(get_node(initial_state).name)

func _process(delta: float) -> void:
	if current_state and not enemy.is_staggered:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state and not enemy.is_staggered:
		current_state.physics_update(delta)

func change_state(state_name: String) -> void:
	print("Changing state from ", current_state.name if current_state else "null", " to ", state_name)
	previous_state = current_state
	
	if current_state:
		current_state.exit()
	
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter()
	else:
		push_error("State " + state_name + " not found in state machine!")

func on_player_detected(player: Node3D) -> void:
	if current_state and not enemy.is_staggered:
		current_state.on_player_detected(player)

func on_player_lost(player: Node3D) -> void:
	if current_state and not enemy.is_staggered:
		current_state.on_player_lost(player)

func on_target_changed(player: Node3D) -> void:
	if current_state and not enemy.is_staggered:
		current_state.on_target_changed(player)

func on_enemy_staggered() -> void:
	if current_state:
		stagger_interrupted = true
		current_state.on_enemy_staggered()

func resume_from_stagger() -> void:
	if stagger_interrupted and current_state:
		stagger_interrupted = false
		current_state.resume_from_stagger()

func on_enemy_death() -> void:
	if current_state:
		current_state.on_enemy_death()
