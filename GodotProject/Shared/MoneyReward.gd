extends Node3D
class_name MoneyReward

const MONEY = "res://Interactibles/Money/Money.tscn"

@export var amount: int = 10
@export var hp_component: Hp
@export var attraction_point: Marker3D

# Money types (big = size indicator, not actual scene)
const CHUNKS = [
	{ "value": 500, "type": "gold", "big": true },
	{ "value": 100, "type": "gold", "big": false },
	{ "value": 50,  "type": "silver", "big": true },
	{ "value": 10,  "type": "silver", "big": false }
]

func _ready() -> void:
	if hp_component:
		hp_component.death.connect(spawn_money)

func spawn_money():
	if amount <= 0:
		return

	var remaining = amount
	for chunk in CHUNKS:
		var count = remaining / chunk["value"]
		remaining %= chunk["value"]

		for _i in range(count):
			var instance = load(MONEY).instantiate() as Money
			instance.value = chunk["value"]
			instance.money_type = chunk["type"]
			instance.big = chunk["big"]
			get_parent().get_parent().add_child(instance)
			instance.apply_visuals()

			# Apply slight random velocity
			#var spawn_offset = Vector3(randf_range(0, 1), 2, randf_range(0, 1))
			instance.position = attraction_point.global_position + Vector3(randf_range(-0.5, 0.5),.5,randf_range(-0.5, 0.5))
			#instance.velocity = Vector3(randf_range(-1.5, 1.5), 1.0, randf_range(-1.5, 1.5)) * randf_range(2, 4)
