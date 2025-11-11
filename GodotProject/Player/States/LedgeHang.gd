extends PlayerState

## Handles ledge hanging mechanics
## Player can climb up, drop down, or jump off from a ledge

var ledge_position: Vector3 = Vector3.ZERO
var wall_position: Vector3 = Vector3.ZERO
var wall_normal: Vector3 = Vector3.ZERO
var hang_offset: Vector3 = Vector3(-0.3, -0.8, 0)  # Offset from ledge where player hangs

func enter(msg := {}) -> void:
	# Extract ledge data from message
	if msg.has("ledge_position"):
		ledge_position = msg["ledge_position"]
	if msg.has("wall_position"):
		wall_position = msg["wall_position"]
	if msg.has("wall_normal"):
		wall_normal = msg["wall_normal"]

	# Stop all movement
	player.velocity = Vector3.ZERO
	player.putting_ranged_weapon_in_hand_enabled = false
	player.is_ledge_grabbing = true

	# Snap player to ledge position
	_snap_to_ledge()

	# Play grab animation
	player.character_skin.grab_ledge()

	print("Ledge grabbed at height: ", ledge_position.y)

func exit() -> void:
	player.is_ledge_grabbing = false
	player.putting_ranged_weapon_in_hand_enabled = true

func physics_update(delta: float) -> void:
	# Keep player frozen at ledge position
	player.velocity = Vector3.ZERO

	# Jump up to climb onto ledge
	if Input.is_action_just_pressed("jump"):
		_climb_up()
		return

	# Drop down from ledge (crouch/down input)
	if Input.is_action_just_pressed("crouch"):
		_drop_down()
		return

	# Move sideways along ledge (optional feature for later)
	# var input_dir = Input.get_axis("move_left", "move_right")
	# if abs(input_dir) > 0.1:
	# 	_shimmy(input_dir, delta)

func _snap_to_ledge() -> void:
	# Calculate hang position based on wall normal and ledge position
	var hang_direction = -wall_normal  # Face away from wall
	hang_direction.y = 0
	hang_direction = hang_direction.normalized()

	# Position player slightly away from wall, below ledge
	var target_position = ledge_position
	target_position += hang_direction * abs(hang_offset.z)  # Away from wall
	target_position.y += hang_offset.y  # Below ledge

	player.global_position = target_position

	# Orient player to face wall
	var face_wall_direction = wall_normal
	face_wall_direction.y = 0
	face_wall_direction = face_wall_direction.normalized()

	if face_wall_direction.length() > 0.1:
		player.rotation_root.transform.basis = Basis.looking_at(face_wall_direction, Vector3.UP)

func _climb_up() -> void:
	# Climb up onto the ledge
	print("Climbing up ledge")

	# Move player up and forward onto ledge
	var climb_target = ledge_position
	climb_target += -wall_normal * 0.5  # Move away from wall onto platform
	climb_target.y += 0.3  # Slight upward boost

	player.global_position = climb_target

	# Give upward and forward velocity
	player.velocity = Vector3.UP * 5.0 + (-wall_normal * 3.0)
	player.velocity.y = 5.0

	# Transition to air state with small upward impulse
	state_machine.transition_to("Air", {do_launch = false})

func _drop_down() -> void:
	# Drop down from ledge
	print("Dropping from ledge")

	# Just transition to air state, letting gravity take over
	state_machine.transition_to("Air")
