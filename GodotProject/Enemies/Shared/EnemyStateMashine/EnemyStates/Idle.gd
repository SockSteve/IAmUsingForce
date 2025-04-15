class_name IdleState
extends EnemyState

var idle_timer: float = 0.0
var idle_duration: float = 1.0

func _ready() -> void:
	await get_tree().process_frame

func enter() -> void:
	print("Entering idle state")
	enemy.should_stop_movement = true
	
	# Delay animation slightly to ensure everything is initialized
	await get_tree().process_frame
	enemy.play_animation("idle")
	
	# Randomize idle duration if we're using it for transitions
	idle_duration = randf_range(
		enemy.ai_config.min_idle_time,
		enemy.ai_config.max_idle_time
	)
	idle_timer = 0.0


func update(delta: float) -> void:
	# Only use the timer if we have a next state to go to
	if idle_timer >= idle_duration:
		# This can be overridden in specific enemy implementations
		pass

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
