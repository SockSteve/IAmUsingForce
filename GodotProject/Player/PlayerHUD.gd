extends Control
class_name PlayerHUD

## This class handles the players anything related to the players heads up display (HUD)
## all values displayed are gotten from the inventory and player, no values related
## to the player or inventory are stored here
const  QUICK_SELECT_ICON_PATH ="%SMIcon_"

@export_range(0,1) var disabled_alpha: float = 0.2
@export_node_path("Inventory") var inventory_path: NodePath
@export_node_path("Player") var player: NodePath

@onready var money_label = %MoneyLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	money_label.text = str(get_node(inventory_path).get_money())
	get_node(inventory_path).money_amount_changed.connect(display_money)
	get_node(inventory_path).quick_select_panel_changed.connect(populate_quick_select_with_weapons)
	
	get_node(player).weapon_changed.connect(_on_weapon_changed)
	
	await get_tree().process_frame
	populate_quick_select_with_weapons(get_node(inventory_path).current_quick_select_panel)
	
func display_money(amount):
	money_label.text = str(amount)


func populate_quick_select_with_weapons(quick_select_index):
	var quick_selections: Dictionary = get_node(inventory_path).weapon_quick_select
	var current_quick_select_panel = quick_selections.get(quick_select_index)
	
	if current_quick_select_panel == null:
		printerr("Error: quick_select_panel is null for index:", quick_select_index)
		return
	
	var player_node = get_node(player)
	var current_melee_weapon = player_node.current_melee_weapon
	var current_ranged_weapon = player_node.current_ranged_weapon
	
	for shortcut_index in current_quick_select_panel:
		var sm_icon: TextureRect = get_node(QUICK_SELECT_ICON_PATH + str(shortcut_index))
		var weapon_name = current_quick_select_panel.get(shortcut_index, null)
		if weapon_name == null:
			sm_icon.texture = null
			sm_icon.modulate.a = disabled_alpha
			continue
		
		var weapon_texture: CompressedTexture2D = get_node(inventory_path).get_weapon(weapon_name).icon
		if weapon_texture == null:
			print("Error: weapon_texture is null for weapon:", weapon_name)
			continue
		
		sm_icon.texture = weapon_texture
		print(current_melee_weapon.name)
		print(current_ranged_weapon.name)
		
		if weapon_name == current_melee_weapon.name:
			sm_icon.modulate = Color(1, 0.5, 0)  # Orange for currently held melee weapon
		elif weapon_name == current_ranged_weapon.name:
			sm_icon.modulate = Color(0, 0.5, 1)  # Blue for currently held ranged weapon
		else:
			sm_icon.modulate = Color(1, 1, 1, disabled_alpha)
			#sm_icon.modulate.a = disabled_alpha
	print("Quick select panel populated:", quick_select_index)

func _on_weapon_changed(weapon_name: StringName):
	print("Weapon changed to:", weapon_name)
	populate_quick_select_with_weapons(get_node(inventory_path).current_quick_select_panel)


#extends TextureRect
#
#var disabled_alpha := 0.2
#
#func _ready():
	#modulate.a = disabled_alpha
#
#func set_state(state: bool):
	#var from_to := [Color(1, 1, 1, disabled_alpha), Color.WHITE]
	#if state : from_to.reverse()
	#var tween := create_tween()
	#tween.tween_property(self, "modulate", from_to[0], 0.2).from(from_to[1])
