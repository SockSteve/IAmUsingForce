extends Node3D

signal got_costumer(costumer: Player)
signal costumer_left()

var customer : Player = null
var player_cam : Camera3D = null
var shop_menu : bool = false
@onready var vendor_cam : Camera3D = $VendorCamera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		shop_menu = not shop_menu
		
		if shop_menu:
			open_shop()
			
		if not shop_menu:
			close_shop()

func open_shop():
	customer.freeze = true
	vendor_cam.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$ShopMenu3D.initialize()

func close_shop():
	$ShopMenu3D.cleanup()
	customer.freeze = false
	player_cam.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	customer._ready()
	$StaticBody3D/Area3D

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		customer = body
		emit_signal("got_costumer", body)
		player_cam = body.find_child("PlayerCamera")
		set_process(true)

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		customer = null
		emit_signal("costumer_left")
		player_cam = null
		set_process(false)
