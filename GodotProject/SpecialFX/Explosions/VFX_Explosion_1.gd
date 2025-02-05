extends Node3D
class_name VFXExplosion

signal explosion_finished

@onready var sparks: GPUParticles3D = $Sparks
@onready var flash: GPUParticles3D = $Flash
@onready var fire: GPUParticles3D = $Fire
@onready var smoke: GPUParticles3D = $Smoke

func _ready() -> void:
	set_physics_process(false)

func emit_explosion()-> void:
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not smoke.emitting:
		explosion_finished.emit()
		set_physics_process(false)
		
	
