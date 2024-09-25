extends Node3D

signal got_costumer(costumer: Player)
signal costumer_left()

var customer : Player = null
var player_cam : Camera3D = null
var player_is_shopping: bool = false
@onready var shop_menu : Node3D = $ShopMenu3D
@onready var vendor_cam : Camera3D = $VendorCamera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		player_is_shopping = not player_is_shopping
		
		if player_is_shopping:
			open_shop()
			
		if not player_is_shopping:
			close_shop()

func open_shop():
	shop_menu.visible = true
	animation_player.play("open_shop")
	get_tree().paused = true
	customer.freeze = true
	emit_signal("got_costumer", customer)
	vendor_cam.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$ShopMenu3D.get_shop_handler().initialize()

func close_shop():
	get_tree().paused = false
	emit_signal("costumer_left")
	$ShopMenu3D.get_shop_handler().cleanup()
	customer.freeze = false
	player_cam.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	customer.set_up_input()
	animation_player.play_backwards("open_shop")
	await animation_player.animation_finished
	shop_menu.visible = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		customer = body
		player_cam = body.find_child("PlayerCamera")
		set_process(true)

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		customer = null
		player_cam = null
		set_process(false)
