#this class handles the logic related to items in the shop
extends Node3D

#enum btn_state_enum {HIDE, SHOW, AMMO}
#enum btn_content_enum {AMMO, GADGETWEAPON, UPGRADE}
var shop_items: Dictionary = {} #item_name : [btn,content,visibility_state]
var thread: Thread
var _costumer: Player = null

const shop_button = preload("res://Scenes/UI/Templates/ShopButton.tscn")
const ammo_button = preload("res://Scenes/UI/Templates/ShopAmmunitionButton.tscn")

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

var last_focused_button

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.game_progression_flags[Globals.game_progression_flag_enum.find_key(Globals.game_progression_flag_enum.beginning)] = true
	thread= Thread.new()
	thread.start(load_all_weapons_and_gadgets)
	var items: Array = thread.wait_to_finish() # items
	await get_tree().process_frame
	populate_shop_with_items(items)
 
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
	#print(item)

## this function loads all weapons and geadgets from the directory
func load_all_weapons_and_gadgets()->Array:
	var shop_weapons_and_gadgets: Array = []
	# relevant dir paths are put in an array so they can be iterated over
	var weapons_and_gadgets_directory_path_array: PackedStringArray = []
	if melee_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(melee_weapon_dir_path)
	if ranged_weapon_dir_path != "": weapons_and_gadgets_directory_path_array.append(ranged_weapon_dir_path)
	if gadget_dir_path != "": weapons_and_gadgets_directory_path_array.append(gadget_dir_path)
	
	#check if something was added -> crash prevention
	if weapons_and_gadgets_directory_path_array.is_empty():
		return shop_weapons_and_gadgets
	
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
					#if not get_tree().get_first_node_in_group("player").get_inventory().has_weapon(file_name.trim_suffix(".tscn")):
					shop_weapons_and_gadgets.append(weapon_or_gadget)
					#shop_weapons_and_gadgets[weapon_or_gadget] = btn_state_enum.SHOW
					#else:
						#shop_weapons_and_gadgets[weapon_or_gadget] = btn_state_enum.HIDE
			
			#after we extracted everyting we go back into the parent folder and 
			#go to the next folder 
			currently_open_folder.change_dir("..")
			
	#returns the filled dictionary
	return shop_weapons_and_gadgets

func populate_shop_with_items(items):
	for item in items:
		var btn: Button = shop_button.instantiate()
		btn.icon = item.icon
		btn.name = item.name
		shop_items[btn.name] = [btn, item]
		shop_hbox_menu.add_child(btn)
		btn.pressed.connect(self.buy_weapon_or_gadget.bind(item))
		if item is Weapon:
			var ammo_btn: Button = ammo_button.instantiate()
			ammo_btn.icon = item.icon
			ammo_btn.name = item.name + "_Ammo"
			shop_items[ammo_btn.name] = [ammo_btn, item]
			shop_hbox_menu.add_child(ammo_btn)
			shop_hbox_menu.move_child(ammo_btn,0)
			ammo_btn.get_child(0).text = "Ammo"
			ammo_btn.visible = false
			ammo_btn.pressed.connect(self.buy_ammo.bind(item))

func update_shop():
	for item: StringName in shop_items:
		
		if _costumer.get_inventory().has_weapon(item):
			shop_items.get(item)[0].visible=false
			
			if _costumer.get_inventory().get_weapon(item).current_ammunition < _costumer.get_inventory().get_weapon(item).max_ammunition:
				shop_items.get(item + "_Ammo")[0].visible=true
			else:
				shop_items.get(item + "_Ammo")[0].visible=false
		
		if _costumer.get_inventory().has_gadget(item):
			shop_items.get(item)[0].visible=false
			
		#check progression
		if not Globals.game_progression_flags.get(Globals.game_progression_flag_enum.find_key(shop_items.get(item)[1].game_progression_flag)):
			shop_items.get(item)[0].visible=false
	
	#add for buy all ammo
	pass

#because every button has an item instance bound to its pressed callable,
#we can hijack the bound argument and use it to fill the current shop gui
#with item detaile
func _on_sub_viewport_gui_focus_changed(item_button: Button):
	#get first signal from array of connections for this signal
	#there is only one function connected to this signal, so we get the first connection
	var dic = item_button.pressed.get_connections().pop_front() 
	if dic == null: return 
	var callable = dic.get("callable") #get the callable from the connection
	var item_inst = callable.get_bound_arguments().pop_front()#get bound argument
	
	#this is used for the buy popup. we don't want to populate anything if
	#the focus changes to the popup
	if item_inst == null:
		return
	#we save our focused btn to go back to if no purchase was made
	last_focused_button = item_button
	
	#here we populate the gui with information
	current_item_picture.texture =  item_inst.icon
	current_item_name_label.text = item_inst.name
	current_item_description_label.text = item_inst.name
	current_item_price_label.text = str(item_inst.shop_price)

func _on_vendor_got_costumer(costumer: Player):
	_costumer = costumer
	update_shop()

func _on_vendor_costumer_left():
	_costumer = null

func _on_accept_transactio_button_pressed():
	print("bought")

func _on_cancel_transaction_button_pressed():
	%BuyItemPopup.visible = false
	shop_hbox_menu.visible = true
	last_focused_button.grab_focus()
	print("cancelled")
