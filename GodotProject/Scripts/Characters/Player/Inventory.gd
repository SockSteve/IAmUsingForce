extends Node3D

@onready var gun = preload("res://Scenes/Characters/Player/Weapons/RangedWeapons/Blaster/Blaster.tscn")

var collected_weapons: Dictionary = {"cutter": true, "gun": true, "melee_gear": false, "wave_punder" : false,"hive_knive": false, 
"shrapnel_cannon": false, "lightning_baller": false, "bad_prank": false, "pocket_rocket": false}
var collected_gadgets: Dictionary = {"booster": false, "hookshot": false, "special_gear": false, 
"magnet": false, "wireless_battery": false, "hacking_device": false}

func _ready():
	load_inventory()


func load_inventory():
	#load inventory from save file
	pass

func parameterize_weapon():
	#initialize weapon with xp
	pass

func collect_weapon():
	pass
	
func collect_gadget():
	pass
