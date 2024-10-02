extends Node
## the name of the flags are used as variables for dictionary values that change

enum GAME_FLAGS {NONE, BEGINNING, NOGO_FOREST_COMPLETED, 
	PELAGIC_COCKROW_COMPLETED, GLAER_GROTTO_COMPLETED, POLYCOLY_COMPLETED, 
	GAME_COMPLETED, GRAPPLING_HOOK_SELLER, GRIND_BOOTS_SELLER, GRIP_GLOVES_SELLER, 
	BOOSTER_SELLER, MAGNET_SELLER}

var game_progression_flags: Dictionary = get_flags.call(GAME_FLAGS)

func get_flags(_flag_enum)->Dictionary:
	var dicc: Dictionary
	for key in GAME_FLAGS.keys():
		dicc[key] = false
	return dicc

func get_flags_by_value(_flag_enum)->Dictionary:
	var dicc: Dictionary
	for value in GAME_FLAGS.values():
		dicc[value] = false
	return dicc
