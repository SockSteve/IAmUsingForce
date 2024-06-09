extends Control

@onready var money_label = $MoneyPanel/MoneyLabel
@export_node_path("Inventory") var inventory_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(inventory_path).money_changed.connect(display_money)
	money_label.text = str(get_node(inventory_path).get_money())

func display_money(amount):
	money_label.text = str(amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
