extends Node

enum game_progression_flag_enum {beginning,nogo_forrest_completed, 
	pelagic_cockcrow_completed, glare_grotto_completed, polycoly_completed, game_completed, test}

enum special_flag_enum {none, grappling_hook_seller, special_gear_seller, 
	booster_seller, magnet_seller}

var game_progression_flags: Dictionary = get_flags.call(game_progression_flag_enum)

var special_flags: Dictionary = get_flags.call(special_flag_enum)

func get_flags(flag_enum)->Dictionary:
	var dicc: Dictionary
	for key in game_progression_flag_enum.keys():
		dicc[key] = false
	return dicc

func get_flags_by_value(flag_enum)->Dictionary:
	var dicc: Dictionary
	for value in game_progression_flag_enum.values():
		dicc[value] = false
	return dicc
