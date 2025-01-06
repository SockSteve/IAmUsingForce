extends RigidBody3D

@onready var SILVER_NUGGET_CUBE = load("res://Interactibles/Money/SilverMesh.tres")
@onready var GOLD_NUGGET_CUBE = load("res://Interactibles/Money/GoldMesh.tres")

enum NuggetType {SILVER_SMALL, SILVER_BIG, GOLD_SMALL, GOLD_BIG}

@export var nugget_type: NuggetType: set = set_type

@onready var money_mesh: MeshInstance3D = $MoneyMesh
@onready var money_collision: CollisionShape3D = $MoneyCollision

@export var gold_value: int = 10  # Value of the clump (gold/silver)
@export var attraction_speed: float = 5.0  # Speed of attraction to the player
@export var ground_level: float = 0.1  # Y position considered as "ground level"

var physics_active: bool = true
var attracted_to_player: bool = false
var player: Node = null

func set_type(new_type):
	match new_type:
		NuggetType.SILVER_SMALL:
			money_mesh.mesh = load("res://Interactibles/Money/SilverMesh.tres")
			gold_value = 10
		NuggetType.SILVER_BIG:
			money_mesh.mesh = load("res://Interactibles/Money/SilverMesh.tres")
			gold_value = 50
		NuggetType.GOLD_SMALL:
			money_mesh.mesh = load("res://Interactibles/Money/GoldMesh.tres")
			gold_value = 100
		NuggetType.GOLD_BIG:
			money_mesh.mesh = load("res://Interactibles/Money/GoldMesh.tres")
			gold_value = 500
			
			

func _ready():
	# Randomize initial velocity for falling and scattering
	linear_velocity = Vector3(randf_range(-2, 2), randf_range(3, 5), randf_range(-2, 2))


func _physics_process(delta):
	if physics_active:
		if attracted_to_player and player:
			# Move toward the player manually
			var direction = (player.global_transform.origin - global_transform.origin).normalized()
			attraction_speed += delta
			global_transform.origin += direction * attraction_speed * delta
	else:
		# Check if the clump has hit the ground
		if global_transform.origin.y <= ground_level:
			deactivate_physics()


func deactivate_physics():
	physics_active = false
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC  # Switch to static mode to disable physics simulation
	linear_velocity = Vector3.ZERO  # Stop movement
	angular_velocity = Vector3.ZERO  # Stop rotation


func player_detected(attractive_player: Player):
	if player:
		return
	physics_active = true
	attracted_to_player = true
	player = attractive_player


func _on_player_collision(player_hurtbox: Node):
	# Handle collection when colliding with the player
	player.get_inventory().add_money(gold_value)  # Assuming the player script has an `add_gold` method
	queue_free()  # Remove the clump


func collect():
	player.get_inventory().add_money(gold_value)
	queue_free()
