extends Resource
class_name Damage

var instigator: Node3D
var source: Weapon
var value: int

func initialize(new_instigator: Node3D, new_value: int, new_weapon: Weapon = null, ):
	instigator = new_instigator
	source = new_weapon
	value = new_value
	
