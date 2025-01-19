extends Node3D

@onready var sfx_attachment: AudioStreamPlayer3D = $SFXAttachment

@export var damage_delay: float = 2.0
@export var lightning_delay: float = 4.0

var owner_enemy: Node3D
var shock_radius: float
var shock_damage: float
var lightning_scene
var lightning_damage

func setup(owner, radius, damage, lightning, lightning_dmg):
	owner_enemy = owner
	shock_radius = radius
	shock_damage = damage
	lightning_scene = lightning
	lightning_damage = lightning_dmg
	sfx_attachment.play()
	start_shock_sequence()

func start_shock_sequence():
	# Deal AoE damage after 2 seconds
	await get_tree().create_timer(damage_delay).timeout
	deal_aoe_damage()
	
	if not lightning_scene:
		return
	
	# Summon lightning after 4 seconds
	await get_tree().create_timer(lightning_delay - damage_delay).timeout
	summon_lightning()

func deal_aoe_damage():
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")  # Assume enemies are in "enemies" group
	for enemy in nearby_enemies:
		if owner_enemy.global_position.distance_to(enemy.global_position) <= shock_radius:
			enemy.apply_damage(shock_damage)  # Custom damage function on the enemy
	
	if !lightning_scene:
		queue_free()

func summon_lightning():
	var lightning = lightning_scene.instantiate()
	lightning.global_position = owner_enemy.global_position
	lightning.damage = lightning_damage
	get_tree().current_scene.add_child(lightning)  # Add lightning to the main scene

	# Wait for the lightning to finish and free
	await lightning.animation_finished
	queue_free()  # Free the shock node after the sequence is complete
