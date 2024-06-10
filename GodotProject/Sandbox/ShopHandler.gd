#this class handles the logic related to items in the shop
extends Node3D

enum btn_state_enum {HIDE, SHOW, AMMO}
var shop_weapons_and_gadgets: Dictionary = {} #item_instance : visibility_state
var thread: Thread
var _costumer: Player = null

@onready var shop_hbox_menu = %ShopItemSelectionField
@onready var current_item_picture =  %ItemPicture
@onready var current_item_name_label = %ItemNameLabel
@onready var current_item_description_label = %ItemInfoLabel
@onready var current_item_price_label = %PriceLabel


@onready var sub_viewport = $"../SubViewport"

@export_category("Shop")
@export_group("Item Folders")
@export_dir var melee_weapon_dir_path: String 
@export_dir var ranged_weapon_dir_path: String 
@export_dir var gadget_dir_path: String 

@export_group("Event Flags")
@export_subgroup("Game")
@export var game_progression_flags: Dictionary = Globals.game_progression_flags
@export_subgroup("Special")

var special_flags_dict: Dictionary = {"grappling_hook_seller": false, "special_gear_seller": false, "booster_seller": false, "magnet_seller": false}
@export var special_flags : Dictionary = {"grappling_hook_seller": false, "special_gear_seller": false, "booster_seller": false, "magnet_seller": false}

var last_focused_button

# Called when the node enters the scene tree for the first time.
func _ready():
	#await get_tree().create_timer(1).timeout
	print(game_progression_flags)
	thread= Thread.new()
	thread.start(load_all_weapons_and_gadgets)
	thread.wait_to_finish()
	#print(shop_weapons_and_gadgets)
	await get_tree().process_frame
	populate_shop_with_items()
 
func buy_ammo():
	pass

func buy_weapon_or_gadget(item):
	if _costumer.get_inventory().get_money() < item.shop_price:
		%InsuficcientMoneyLabel.visible = true
		await get_tree().create_timer(2).timeout
		%InsuficcientMoneyLabel.visible = false
		return
	
	%BuyItemPopup.visible = true
	shop_hbox_menu.visible = false
	%AcceptTransactioButton.grab_focus()
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
			for file_name:String in currently_open_folder.get_files():
				
				if !file_name.match("*Bullet*") and file_name.match("*.tscn*"):
					var weapon_or_gadget = load(currently_open_folder.get_current_dir() + "/" + file_name)
					
					weapon_or_gadget = weapon_or_gadget.instantiate()
					if not get_tree().get_first_node_in_group("player").get_inventory().has_weapon(file_name.trim_suffix(".tscn")):
						shop_weapons_and_gadgets[weapon_or_gadget] = btn_state_enum.SHOW
					else:
						shop_weapons_and_gadgets[weapon_or_gadget] = btn_state_enum.HIDE
			
			#after we extracted everyting we go back into the parent folder and 
			#go to the next folder 
			currently_open_folder.change_dir("..")
			
	#returns the filled dictionary
	return shop_weapons_and_gadgets

func populate_shop_with_items():
	for item in shop_weapons_and_gadgets:
		var btn: Button = Button.new()
		btn.icon = item.icon
		btn.name = item.name
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

#because every button has an item instance bound to its pressed callable,
#we can hijack the bound argument and use it to fill the current shop gui
#with item detaile
func _on_sub_viewport_gui_focus_changed(item_button: Button):
	
	var dic = item_button.pressed.get_connections().pop_front() #get Array of connections for this signal
	 #there is only one function connected to this signal, so we get the first connection
	var callable = dic.get("callable") #get the callable from the connection
	var item_inst = callable.get_bound_arguments().pop_front()
	if item_inst == null:
		return
	print(item_inst) #get the bound arguments array (here: corresponding weapon instance)
	last_focused_button = item_button
	#print(node.pressed.get_object())
	current_item_picture.texture =  item_inst.icon
	current_item_name_label.text = item_inst.name
	current_item_description_label.text = item_inst.name
	current_item_price_label.text = str(item_inst.shop_price)

func _on_vendor_got_costumer(costumer: Player):
	_costumer = costumer

func _on_vendor_costumer_left():
	_costumer = null

func _on_accept_transactio_button_pressed():
	print("bought")

func _on_cancel_transaction_button_pressed():
	%BuyItemPopup.visible = false
	shop_hbox_menu.visible = true
	last_focused_button.grab_focus()
	print("cancelled")
