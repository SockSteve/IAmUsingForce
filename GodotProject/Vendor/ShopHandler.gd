## This class handles the logic related to items in the shop
extends Node3D

## shop_items contains all the items the shop can sell
var shop_items: Dictionary = {} # item_name: stringName : [btn: Button,weapon_or_gadget_ref]

## thread is used for asynchronous loading of items, because depending on the amount, we don't want the main thread to be cluttered by it
var thread: Thread 

## ref to the player that is currently using this shop
var _costumer: Player = null

##here we load button templates used for selecting items and ammo
const shop_button = preload("res://Scenes/UI/Templates/ShopButton.tscn")
const ammo_button = preload("res://Scenes/UI/Templates/ShopAmmunitionButton.tscn")

@onready var shop_hbox_menu = %ShopItemSelectionField
@onready var current_item_picture =  %ItemPicture
@onready var current_item_name_label = %ItemNameLabel
@onready var current_item_description_label = %ItemInfoLabel
@onready var current_item_price_label = %PriceLabel
@onready var insufficient_money_label = %InsuficcientMoneyLabel
@onready var insufficient_money_label_timer = %InsufficientMoneyMessageTimer
@onready var buy_all_ammo_popup : Panel = %BuyAllAmmoPopup
@onready var accept_all_ammo_btn: Button = %AcceptAllAmmonTransactionButton
@onready var cancel_all_ammo_btn: Button = %CancelAllAmmoTransactionButton
@onready var ui_focus_sfx: AudioStreamPlayer = %UiFocusChangedSfx

@onready var sub_viewport = $"../SubViewport"

@export_category("Shop")
@export_group("Item Folders")
@export_dir var melee_weapon_dir_path: String 
@export_dir var ranged_weapon_dir_path: String 
@export_dir var gadget_dir_path: String 

var last_focused_button
@onready var default_focused_button = %AllAmmoBtn
var current_item_to_be_bought: Item3D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	# use threading to lead weapons
	thread= Thread.new()
	thread.start(load_all_weapons_and_gadgets)
	var items: Array = thread.wait_to_finish() # items
	
	await get_tree().process_frame
	populate_shop_with_items(items)
 
func initialize():
	for child_idx in shop_hbox_menu.get_child_count():
		if shop_hbox_menu.get_child(child_idx).visible:
			shop_hbox_menu.get_child(child_idx).grab_focus()
			break

func cleanup():
	$"../SubViewport/Control".release_focus()
	$"../SubViewport".gui_get_focus_owner().release_focus()

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
		push_warning("no paths found to load into vendor")
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
				
				if file_name.match("*Weapon*") or file_name.match("*Gadget*") and file_name.match("*.tscn*"):
					var weapon_or_gadget = load(currently_open_folder.get_current_dir() + "/" + file_name)
					weapon_or_gadget = weapon_or_gadget.instantiate()
					shop_weapons_and_gadgets.append(weapon_or_gadget)
				
			currently_open_folder.change_dir("..")
			
	#returns the filled dictionary
	return shop_weapons_and_gadgets

func populate_shop_with_items(items):
	for item: Item3D in items:
		var btn: Button = shop_button.instantiate()
		btn.icon = item.get_icon()
		btn.name = item.get_id()
		shop_items[btn.name] = [btn, item]
		shop_hbox_menu.add_child(btn)
		btn.pressed.connect(self.buy_weapon_or_gadget.bind(item))
		
		if item is Weapon:
			var ammo_btn: Button = ammo_button.instantiate()
			ammo_btn.icon = item.get_icon()
			ammo_btn.name = item.get_id() + "_ammo"
			shop_items[ammo_btn.name] = [ammo_btn, item]
			shop_hbox_menu.add_child(ammo_btn)
			shop_hbox_menu.move_child(ammo_btn,0)
			ammo_btn.get_child(0).text = "Ammo"
			ammo_btn.visible = false
			ammo_btn.pressed.connect(self.buy_ammo.bind(item))

func update_shop():
	for item_id: StringName in shop_items:
		if _costumer.get_inventory().has_weapon(item_id):
			shop_items.get(item_id)[0].visible=false
			
			if _costumer.get_inventory().get_weapon(item_id).get_current_ammo() < _costumer.get_inventory().get_weapon(item_id).get_max_ammo():
				shop_items.get(item_id + "_ammo")[0].visible=true
			
			if  _costumer.get_inventory().get_weapon(item_id).get_current_ammo() == _costumer.get_inventory().get_weapon(item_id).get_max_ammo():
				shop_items.get(item_id + "_ammo")[0].visible=false
		
		if _costumer.get_inventory().has_gadget(item_id):
			shop_items.get(item_id)[0].visible=false
			
		#check progression
		#if not Globals.game_progression_flags.get(Globals.game_progression_flag_enum.find_key(shop_items.get(item)[1].game_progression_flag)):
			#shop_items.get(item)[0].visible=false
	

#because every button has an item instance bound to its pressed callable,
#we can hijack the bound argument and use it to fill the current shop gui
#with item detaile
func _on_sub_viewport_gui_focus_changed(item_button):
	#the item_button can be a slider and we dont want to do anything here then
	if not item_button is Button:
		return
	
	#get first signal from array of connections for this signal
	#there is only one function connected to this signal, so we get the first connection
	var dic = item_button.pressed.get_connections().pop_front() 
	if dic == null : return 
	ui_focus_sfx.play()
	var callable = dic.get("callable") #get the callable from the connection
	var item_inst: Item3D = callable.get_bound_arguments().pop_front()#get bound argument
	
	#this is used for the buy popup. we don't want to populate anything if
	#the focus changes to the popup
	if item_inst == null:
		return
	#we save our focused btn to go back to if no purchase was made
	last_focused_button = item_button
	
	#here we populate the gui with information
	current_item_picture.texture =  item_inst.get_icon()
	current_item_name_label.text = item_inst.get_custom_name()
	current_item_description_label.text = item_inst.get_description()
	current_item_price_label.text = str(item_inst.get_shop_price())

## item can be weapon or gadget
func buy_weapon_or_gadget(item:Item3D):
	if _costumer.get_inventory().get_money() < item.get_shop_price():
		insufficient_money_label.visible = true
		insufficient_money_label_timer.start()
		await insufficient_money_label_timer.timeout
		insufficient_money_label.visible = false
		return
	current_item_to_be_bought = item
	%BuyItemPopup.visible = true
	shop_hbox_menu.visible = false
	%AcceptItemTransactionButton.grab_focus()


func buy_ammo(weapon: Weapon):
	var current_costumer_money: int = _costumer.get_inventory().get_money()
	if weapon.get_ammo_shop_price() <= 0:
		print("i can't give credit")
	if current_costumer_money < weapon.get_ammo_shop_price():
		insufficient_money_label.visible = true
		insufficient_money_label_timer.start()
		await insufficient_money_label_timer.timeout
		insufficient_money_label.visible = false
		return
		
	current_item_to_be_bought = _costumer.get_inventory().get_weapon(weapon.get_id()) as Weapon
	print("let me in")
	%BuyAmmoPopup.visible = true
	shop_hbox_menu.visible = false
	var ammo_needed: int  = current_item_to_be_bought.get_max_ammo() - current_item_to_be_bought.get_current_ammo()
	var max_ammo_affordable: int = int(current_costumer_money / current_item_to_be_bought.get_ammo_shop_price())
	var ammo_max_amount_to_buy: int = min(ammo_needed, max_ammo_affordable)
	
	%AmmoAmountSlider.max_value = ammo_max_amount_to_buy
	%AmmoAmountSlider.value = ammo_max_amount_to_buy
	%CurrentAmmoLabel.text = str(ammo_max_amount_to_buy)
	%MaxAmmoLabel.text = str(ammo_max_amount_to_buy)
	%AmmoAmountSlider.grab_focus()


func _on_vendor_got_costumer(costumer: Player):
	_costumer = costumer
	update_shop()


func _on_vendor_costumer_left():
	_costumer = null


func _on_ammo_amount_slider_value_changed(value):
	%CurrentAmmoLabel.text = str(value)


func _on_accept_item_transaction_button_pressed():
	_costumer.get_inventory().remove_money(current_item_to_be_bought.get_shop_price())
	_costumer.get_inventory().add_weapon_or_gadget(current_item_to_be_bought.get_id(),current_item_to_be_bought)
	update_shop()
	%BuyItemPopup.visible = false
	shop_hbox_menu.visible = true
	default_focused_button.grab_focus()


func _on_cancel_item_transaction_button_pressed():
	%BuyItemPopup.visible = false
	shop_hbox_menu.visible = true
	last_focused_button.grab_focus()


func _on_accept_ammo_transaction_button_pressed():
	var money_to_be_payed: int = int(%AmmoAmountSlider.value) * current_item_to_be_bought.get_ammo_shop_price()
	_costumer.get_inventory().remove_money(money_to_be_payed)
	current_item_to_be_bought.current_ammo += int(%AmmoAmountSlider.value)
	%BuyAmmoPopup.visible = false
	shop_hbox_menu.visible = true
	update_shop()
	default_focused_button.grab_focus()


func _on_cancel_ammo_transaction_button_pressed():
	%BuyAmmoPopup.visible = false
	shop_hbox_menu.visible = true
	last_focused_button.grab_focus()

var total_price: int = 0
func _on_all_ammo_btn_pressed():
	for weapon: Weapon in _costumer.get_inventory().get_all_weapons():
		if weapon.get_current_ammo() != weapon.get_max_ammo():
			var bullet_diff = weapon.get_max_ammo() - weapon.get_current_ammo()
			total_price += bullet_diff * weapon.get_ammo_shop_price()
	if total_price == 0:
		return
	buy_all_ammo_popup.visible = true
	shop_hbox_menu.visible = false
	accept_all_ammo_btn.grab_focus()


func _on_accept_all_ammon_transaction_button_pressed():
	_costumer.get_inventory().remove_money(total_price)
	for weapon: Weapon in _costumer.get_inventory().get_all_weapons():
		weapon.current_ammo = weapon.get_max_ammo()
	total_price = 0
	update_shop()
	buy_all_ammo_popup.visible = false
	shop_hbox_menu.visible = true
	default_focused_button.grab_focus()


func _on_cancel_all_ammo_transaction_button_pressed():
	buy_all_ammo_popup.visible = false
	shop_hbox_menu.visible = true
	last_focused_button.grab_focus()
