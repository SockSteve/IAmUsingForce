extends Node3D

@onready var sfx_attachment: AudioStreamPlayer3D = $SFXAttachment
@export var damage_delay: float = 2.0
@export var lightning_delay: float = 4.0

var owner_enemy: Node3D
var shock_radius: float
var shock_damage: float
@onready var lightnin_vfx: Node3D = $LightninVFX
var lightning_damage = 1000
var time: float = 0.0
var casted_lightning = false

func setup(owner, radius, damage):
	owner_enemy = owner
	shock_radius = radius
	shock_damage = damage
	#start_shock_sequence()

func _physics_process(delta: float) -> void:
	time += delta
	if time >= 4.0 and not casted_lightning:
		casted_lightning = true
		summon_lightning()
	if time >= 5.0:
		queue_free()
	

#func start_shock_sequence():
	# Deal AoE damage after 2 seconds
	#await get_tree().create_timer(damage_delay).timeout
	#deal_aoe_damage()
	
	# Summon lightning after 4 seconds
	#summon_lightning()

func deal_aoe_damage():
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")  # Assume enemies are in "enemies" group
	for enemy in nearby_enemies:
		if owner_enemy.global_position.distance_to(enemy.global_position) <= shock_radius:
			enemy.apply_damage(shock_damage)  # Custom damage function on the enemy
	
	queue_free()

func summon_lightning():
	var lightning = $LightninVFX/GPUParticles3D
	lightning.global_position = owner_enemy.global_position
	lightning.emitting = true
