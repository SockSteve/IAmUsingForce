extends Node3D

enum btn_state_enum {HIDE, SHOW, AMMO}
var shop_weapons_and_gadgets: Dictionary = {}
var thread: Thread

@onready var shop_hbox_menu = %ShopHBoxWindow
@export_dir var melee_weapon_dir_path: String 
@export_dir var ranged_weapon_dir_path: String 
@export_dir var gadget_dir_path: String 

# Called when the node enters the scene tree for the first time.
func _ready():
	thread= Thread.new()
	thread.start(load_all_weapons_and_gadgets)
	thread.wait_to_finish()
	#print(shop_weapons_and_gadgets)
	populate_shop_with_items()
 
func buy_ammo():
	pass

func buy_weapon_or_gadget(item):
	print(item)

func load_all_weapons_and_gadgets():
	# relevant dir paths are put in an array so they can be iterated over
	var weapons_and_gadgets_directory_path_array: PackedStringArray = []
	if melee_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(melee_weapon_dir_path)
	if ranged_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(ranged_weapon_dir_path)
	if gadget_dir_path != "": weapons_and_gadgets_directory_path_array.append(gadget_dir_path)
	
	#check if something was added -> crash prevention
	if weapons_and_gadgets_directory_path_array.is_empty():
		return
	
	#here we iterate through the array with the previously defined paths
	for directory_path in weapons_and_gadgets_directory_path_array:
		var currently_open_folder =  DirAccess.open(directory_path)
		
		#we get all sub directories of the current directory and iterate over them
		for sub_dir in currently_open_folder.get_directories():
			#we go into each directory to get to the files inside
			currently_open_folder.change_dir(sub_dir)
			
			#we extract all relevant scene paths and store them for use
			for file_name in currently_open_folder.get_files():
				if !file_name.match("*Bullet*") and file_name.match("*.tscn*"):
					var weapon_or_gadget = load(currently_open_folder.get_current_dir() + "/" + file_name)
					weapon_or_gadget = weapon_or_gadget.instantiate()
					shop_weapons_and_gadgets[weapon_or_gadget] = btn_state_enum.SHOW
			
			#after we extracted everyting we go back into the parent folder and 
			#go to the next folder 
			currently_open_folder.change_dir("..")
			
	#returns the filled dictionary
	return shop_weapons_and_gadgets

func populate_shop_with_items():
	for item in shop_weapons_and_gadgets:
		var btn: Button = Button.new()
		btn.icon = item.icon
		#btn.name = item.name
		#btn.pressed.connect(self._on_button_pressed.bind(item))
		shop_hbox_menu.add_child(btn)
		match shop_weapons_and_gadgets.get(item):
			btn_state_enum.HIDE:
				btn.hide()
			btn_state_enum.SHOW:
				btn.pressed.connect(self.buy_weapon_or_gadget.bind(item))
				btn.show()
			btn_state_enum.AMMO:
				btn.pressed.connect(self.buy_ammo.bind(item))

func load_shop_state():
	#check world progression flags and make items visible accordingly
	
	#check player inventory which gadgets and weapons he already has
	
	#replace bought weapons with ammo for it in shop, if ammo is not max
	#add for buy all ammo
	pass

func update_shop():
	pass
