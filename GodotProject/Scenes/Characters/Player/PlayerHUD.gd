extends Control
class_name PlayerHUD

## This class handles the players anything related to the players heads up display (HUD)
## all values displayed are gotten from the inventory and player, no values related
## to the player or inventory are stored here
@export_range(0,1) var disabled_alpha: float = 0.2
@export_node_path("Inventory") var inventory_path: NodePath
@export_node_path("Player") var player: NodePath

@onready var money_label = $MoneyPanel/MoneyLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	money_label.text = str(get_node(inventory_path).get_money())
	get_node(inventory_path).money_amount_changed.connect(display_money)
	get_node(inventory_path).quick_select_panel_changed.connect(populate_quick_select_with_weapons)
	await get_tree().process_frame
	populate_quick_select_with_weapons(get_node(inventory_path).current_quick_select_panel)
	
func display_money(amount):
	money_label.text = str(amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populate_quick_select_with_weapons(quick_select_index):
	var sm_icon_path : String = "%SMIcon_"
	var quick_selections: Dictionary = get_node(inventory_path).weapon_quick_select
	var current_quick_select_panel = quick_selections.get(quick_select_index)
	for shortcut_index in current_quick_select_panel:
		var sm_icon: TextureRect = get_node(sm_icon_path + str(shortcut_index))
		var weapon_texture: CompressedTexture2D = get_node(inventory_path).get_weapon(current_quick_select_panel.get(shortcut_index)).icon
		sm_icon.texture = weapon_texture
		sm_icon.modulate.a = disabled_alpha

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
