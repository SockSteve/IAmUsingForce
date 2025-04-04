extends Node3D
class_name Hit

signal hit_finished

@onready var hit_effect: GPUParticles3D = $HitEffect
@onready var sparks: GPUParticles3D = $Sparks

func _ready() -> void:
	set_physics_process(false)

func emit_explosion()-> void:
	sparks.emitting = true
	hit_effect.emitting = true
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not sparks.emitting and not hit_effect.emitting:
		hit_finished.emit()
		set_physics_process(false)
