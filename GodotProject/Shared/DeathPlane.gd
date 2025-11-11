extends Area3D
class_name DeathPlane

## Teleports player to a respawn point when they fall out of bounds
## Place this below your level geometry to catch falling players

@export var respawn_marker: Marker3D  ## Marker3D to teleport player to
@export var reset_velocity: bool = true  ## Reset player velocity on respawn
@export var play_respawn_sound: bool = false  ## Optional respawn sound effect
@export var respawn_sound: AudioStream  ## Sound to play on respawn

func _ready() -> void:
	# Connect to body entered signal
	body_entered.connect(_on_body_entered)

	# Validate respawn marker
	if not respawn_marker:
		push_warning("DeathPlane: No respawn marker set! Player will respawn at origin.")

	# Setup collision layers
	# Only detect player (layer 1)
	collision_layer = 0
	collision_mask = 1

func _on_body_entered(body: Node3D) -> void:
	# Check if it's the player
	if body.is_in_group("players") or body is Player:
		respawn_player(body)

func respawn_player(player: Node) -> void:
	# Determine respawn position
	var respawn_position: Vector3
	if respawn_marker:
		respawn_position = respawn_marker.global_position
	else:
		respawn_position = Vector3.ZERO  # Fallback to origin

	# Teleport player
	player.global_position = respawn_position

	# Reset velocity if requested
	if reset_velocity and player.has_method("get_velocity"):
		player.velocity = Vector3.ZERO

	# Play sound effect if configured
	if play_respawn_sound and respawn_sound:
		_play_respawn_sound(respawn_position)

	print("DeathPlane: Respawned player at ", respawn_position)

func _play_respawn_sound(position: Vector3) -> void:
	# Create temporary audio player for one-shot sound
	var audio_player = AudioStreamPlayer3D.new()
	get_tree().root.add_child(audio_player)
	audio_player.global_position = position
	audio_player.stream = respawn_sound
	audio_player.play()

	# Auto-cleanup after sound finishes
	audio_player.finished.connect(func(): audio_player.queue_free())
