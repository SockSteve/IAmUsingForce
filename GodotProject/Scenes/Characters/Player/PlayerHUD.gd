extends Control

@onready var money_label = $MoneyPanel/MoneyLabel
@export_node_path("Inventory") var inventory_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	money_label.text = str(get_node(inventory_path).get_money())
	get_node(inventory_path).money_amount_changed.connect(display_money)
	await get_tree().process_frame
	populate_shortcutsmenu_with_weapons()
	
func display_money(amount):
	money_label.text = str(amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populate_shortcutsmenu_with_weapons():
	#get_node("ShortcutMenu/SMMiddleSection/HBoxContainer/SMIcon_0")
	var sm_icon_path : StringName = "%SMIcon_"
	for shortcut_panel in get_node(inventory_path).weapon_shortcuts.values():
		for shortcut_index in shortcut_panel:
			shortcut_index
			var sm_icon: TextureRect = get_node(sm_icon_path + str(shortcut_index))
			var weapon_texture = get_node(inventory_path).get_weapon(shortcut_panel.get(shortcut_index)).icon
			sm_icon.texture = weapon_texture
	#print(trimmed_string)  # This will print "kkeke/laylow"
	
