# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
# Updated to work with new Player manager system
extends Node
class_name StateMachine

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
@onready var state: State = get_node(initial_state)

# Coyote time variables
var coyote_time_duration: float = 0.1
var coyote_timer: float = 0.0
var was_on_floor: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	state.enter()

# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	_update_coyote_time(delta)
	state.physics_update(delta)

# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) ->void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)

# Methods for handling input from the new manager system
func handle_jump() -> void:
	if state.has_method("handle_jump"):
		state.handle_jump()

func handle_dodge() -> void:
	if state.has_method("handle_dodge"):
		state.handle_dodge()

func handle_crouch() -> void:
	if state.has_method("handle_crouch"):
		state.handle_crouch()

func handle_attack(attack_type: String) -> void:
	if state.has_method("handle_attack"):
		state.handle_attack(attack_type)

# Coyote time functionality
func _update_coyote_time(delta: float) -> void:
	var player = owner as Player
	if not player:
		return
	
	var is_on_floor = player.is_on_floor()
	
	# Start coyote timer when leaving the ground
	if was_on_floor and not is_on_floor:
		coyote_timer = coyote_time_duration
	
	# Count down coyote timer
	if coyote_timer > 0:
		coyote_timer -= delta
	
	was_on_floor = is_on_floor

func can_coyote_jump() -> bool:
	return coyote_timer > 0.0

func use_coyote_jump() -> void:
	coyote_timer = 0.0
