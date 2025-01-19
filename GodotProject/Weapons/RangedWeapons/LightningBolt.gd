extends Node3D

@export var damage: float = 0.0

@onready var sfx_lightning: AudioStreamPlayer3D = $SFXLightning
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal animation_finished

func get_stats():
	return

func _ready():
	# Play SFX and animation
	sfx_lightning.play()
	animation_player.play("strike")

	# Wait for animation and SFX to finish
	await animation_player.animation_finished
	await sfx_lightning.finished
	emit_signal("animation_finished")
	queue_free()
