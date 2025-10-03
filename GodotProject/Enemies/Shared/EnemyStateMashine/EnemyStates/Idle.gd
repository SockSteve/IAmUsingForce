class_name IdleState
extends EnemyState

var idle_timer: float = 0.0
var idle_duration: float = 1.0

func _ready() -> void:
	await get_tree().process_frame

func enter() -> void:
	print("Entering idle state")
	enemy.should_stop_movement = true
	
	await get_tree().process_frame
	enemy.play_animation("idle")
	
	idle_duration = randf_range(
		enemy.ai_config.min_idle_time,
		enemy.ai_config.max_idle_time
	)
	idle_timer = 0.0

func update(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= idle_duration:
		# Can be overridden in specific implementations
		pass

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
