extends Node3D

@onready var sparks: GPUParticles3D = $Sparks
@onready var flash: GPUParticles3D = $Flash
@onready var fire: GPUParticles3D = $Fire
@onready var smoke: GPUParticles3D = $Smoke

func emit_explosion()-> void:
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
	
