extends Node


#@export var collected_game_flags: Array[Globals.GAME_FLAGS]
#
#var save_game_resource : SaveGameResource
#
#func save_game():
	#save_game_resource = SaveGameResource.new()
	##find every object working with persistent data
	#
	##write persistenet data into save_game_resource
	##save resource
	#
	#var result = ResourceSaver.save(save_game_resource,"res://Savegame/save_test.tres")
	#if result == OK:
		#print("Scene saved successfully.")
	#else:
		#print("Failed to save scene.")
	#
#func load_game():
	#if not ResourceLoader.exists("res://Savegame/save_test.tres"):
		#pass
	#var saved_game_data = load("res://Savegame/save_test.tres") as SaveGameResource
	
