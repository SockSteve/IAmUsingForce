extends Area3D
class_name Money

@export var value: int = 10
@export var money_type: String = "silver"  # Either "gold" or "silver"
@export var big: bool = false
@export var attraction_speed: float = 10.0

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var money_mesh: MeshInstance3D = $MoneyMesh
@onready var texture_gold = preload("res://Interactibles/Money/MoneyGold.material")
@onready var texture_silver = preload("res://Assets/Models/Interactibles/SilverNugget_Metal003_2K-JPG_Color.jpg")

var velocity: Vector3 = Vector3.ZERO
var player: Node = null
var attracted_to_player: bool = false

func _ready():
	apply_visuals()

func apply_visuals():
	# Set texture based on type
	var texture = texture_gold if money_type == "gold" else texture_silver
	money_mesh.set_surface_override_material(0,texture)

	# Scale up for "big" money
	if big:
		money_mesh.scale = money_mesh.scale * 1.5

func _physics_process(delta):
	if not ray_cast_3d.is_colliding() and not player:
		global_position.y -= delta

	# Chase the player if detected
	if attracted_to_player and player:
		var direction = (player.attraction_point.global_position - global_position).normalized()
		global_position += direction * attraction_speed * delta

func player_detected(player_node: Node):
	if player:
		return
	player = player_node
	attracted_to_player = true
	
func _on_collected():
	player.get_inventory().add_money(value)
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	body.get_inventory().add_money(value)
	queue_free()
