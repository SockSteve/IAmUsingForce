extends Resource
class_name Damage

var instigator: Node3D
var source: Weapon
var value: int
var impact_point: Vector3
var force: float

func initialize(new_instigator: Node3D, new_value: int, new_weapon: Weapon = null, new_impact_point: Vector3 = Vector3.ZERO, new_force: float = 0.0):
	instigator = new_instigator
	source = new_weapon
	value = new_value
	impact_point = new_impact_point
	force = new_force
	
