extends Node3D
class_name MoneyReward

signal activate

@export var amount: int = 10
@export var hp_component: Hp

func _ready() -> void:
	if not hp_component:
		return
	hp_component.death.connect(spawn_money)

func spawn_money():
	if amount >= 0:
		return
	var remaining = amount

	var chunks = [
		{ "scene": InstanceLoader.gold, "value": 500 },
		{ "scene": InstanceLoader.gold, "value": 100 },
		{ "scene": InstanceLoader.silver, "value": 50 },
		{ "scene": InstanceLoader.silver, "value": 10 }
	]
	for chunk in chunks:
		var count = remaining / chunk["value"]  # How many of this chunk can we use?
		remaining %= chunk["value"]  # Get remainder

		for i in range(count):
			var instance = chunk["scene"].instantiate() as Money
			if chunk["value"] == 500 || chunk["value"] == 50:
				instance.big = true
			get_parent().add_child(instance)
			instance.global_position = global_position + Vector3(randi_range(-10, 10), randi_range(1, 10), randi_range(-10, 10))  # Random spawn
	
	if remaining > 0:
		print("Warning: Amount left unhandled:", remaining)  # Shouldn't happen if values are multiples of 10
	
