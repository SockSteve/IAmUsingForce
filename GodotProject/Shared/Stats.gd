class_name Stats
extends Node

@export var _owner: Node3D
@export var health: int = 100 # Default health value.
@export var xp_reward: int = 50 # XP given upon death.
@export var gold_reward: int = 10 # Gold given upon death.
@export var material_for_red_flash: MeshInstance3D
@onready var original_material := material_for_red_flash.get_surface_override_material(0).duplicate()

func take_damage(damage: Damage) -> void:
	flash_red()
	health -= damage.value
	if health <= 0:
		die(damage)

# Function to handle death.
func die(damage_source: Damage) -> void:
	print(damage_source)
	damage_source.source.add_xp(xp_reward)
	damage_source.instigator.get_inventory().add_money(gold_reward)
	queue_free() # Remove this enemy from the scene.

func flash_red():
	var mat = material_for_red_flash.get_surface_override_material(0)
	if mat:
		#mat.albedo_color = Color(1, 0, 0)  # Set to red
		mat.albedo_color = Color(2, 1, 1)
		await get_tree().create_timer(0.2).timeout  # Wait for 0.2 seconds
		mat.albedo_color = original_material.albedo_color  # Restore original color
