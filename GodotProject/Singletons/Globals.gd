@tool
extends Node

enum game_progression_flag_enum {nogo_forrest_completed, 
	pelagic_cockcrow_completed, glare_grotto_completed, polycoly_completed}

enum special_flag_enum {grappling_hook_seller, special_gear_seller, 
	booster_seller, magnet_seller}

var  game_progression_flags = get_flags(game_progression_flag_enum)
var special_flags = get_flags(special_flag_enum)

func get_flags(flag_enum)->Dictionary:
	var dicc: Dictionary
	for key in flag_enum.keys():
		dicc[key] = false
	return dicc
