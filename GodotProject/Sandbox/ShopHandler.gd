extends Node3D

@onready var shop_hbox_menu = %ShopHBoxWindow
@export_dir var melee_weapon_dir_path: String
@export_dir var ranged_weapon_dir_path: String
@export_dir var gadget_dir_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	get_all_weapons_and_gadgets()
	pass # Replace with function body.

func buy_weapon_or_gadget():
	pass
	
func buy_ammo():
	pass

func _on_button_pressed():
	var directory = DirAccess.get_files_at("res://Scenes/Weapons/")
	var weapon_dir = DirAccess.get_directories_at("res://Scenes/Weapons/")
	print(weapon_dir)

func get_all_weapons_and_gadgets():
	var weapons_and_gadgets_directory_path_array: PackedStringArray = []
	if melee_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(melee_weapon_dir_path)
	if ranged_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(ranged_weapon_dir_path)
	if gadget_dir_path != "": weapons_and_gadgets_directory_path_array.append(gadget_dir_path)
	
	if weapons_and_gadgets_directory_path_array.is_empty():
		return
		
	print(weapons_and_gadgets_directory_path_array)
	
	for directory_path in weapons_and_gadgets_directory_path_array:
		print(directory_path)
		var currently_open_directory =  DirAccess.open(directory_path)
		for sub_dir in currently_open_directory.get_directories():
			currently_open_directory.change_dir(sub_dir)
			print(currently_open_directory.get_files())
			currently_open_directory.change_dir("..")

#func dir_contents(path: String):
	#var melee_weapon_directory = DirAccess.open(melee_weapon_dir)
	#for sub_dir in melee_weapon_directory.get_directories():
		#melee_weapon_directory.change_dir(sub_dir)
		#print(melee_weapon_directory.get_files())
		#melee_weapon_directory.change_dir("..")
	
	#var unique_weapon_directories: PackedStringArray = DirAccess.get_directories_at(melee_weapon_dir)
	#unique_weapon_directories.append_array(DirAccess.get_directories_at(ranged_weapon_dir))
	#print(unique_weapon_directories)
	#var weapon_paths:PackedStringArray = []
	#for unique_weapon_path in unique_weapon_directories
	
	#get_files_at(path: String)
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name: String = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#print("Found directory: " + file_name)
				#
				#var sub_dir = DirAccess.open(path + file_name)
				#if sub_dir:
					#sub_dir.list_dir_begin()
					#var sub_dir_file_name: String = sub_dir.get_next()
					#while sub_dir_file_name != "":
						#if dir.current_is_dir():
							#print("Found directory: " + sub_dir_file_name)
						#else:
							#print("Found file: " + sub_dir_file_name)
						#sub_dir_file_name = dir.get_next()
			#else:
				#print("Found file: " + file_name)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
