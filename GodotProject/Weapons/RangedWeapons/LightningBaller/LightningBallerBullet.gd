extends CharacterBody3D

var linear_velocity = Vector3.ZERO

@export var speed: float = 40.0
@export var bounce_count: int = 3  # How many times the bullet can bounce
@export var shock_radius: float = 5.0
@export var shock_damage: float = 10.0
@export var lightning_damage: float = 50.0

@onready var sfx_bounce: AudioStreamPlayer3D = $SFXBounce
#@onready var shock_scene = preload("res://Weapons/RangedWeapons/LightningBaller/ShockStatus.tscn")  # Scene for the shock
#@onready var lightning_scene = preload("res://Weapons/RangedWeapons/LightningBaller/LightningBolt.tscn")  # Scene for the lightning bolt

var direction: Vector3 = Vector3.ZERO
var remaining_bounces: int

func _ready():
	remaining_bounces = bounce_count

func _physics_process(delta):
	move_and_slide()

	# Check collisions
	if get_slide_collision_count() > 0:
		handle_collision(get_slide_collision(0))

func handle_collision(collision: KinematicCollision3D):
	var collider = collision.collider

	if collider is EnemyBase:  # If the bullet hits an enemy
		shock_enemy(collider)
		bounce(collision.normal)
	elif collider is StaticBody3D:  # If the bullet hits a wall
		bounce(collision.normal)

func shock_enemy(enemy):
	if enemy.has_node("ShockNode"):  # Ensure an enemy can't be shocked multiple times
		return

	#var shock_instance = shock_scene.instantiate()
	#shock_instance.setup(enemy, shock_radius, shock_damage, lightning_scene, lightning_damage)
	#enemy.add_child(shock_instance)  # Attach the shock to the enemy

func bounce(normal: Vector3):
	if remaining_bounces > 0:
		direction = direction.bounce(normal).normalized()
		remaining_bounces -= 1
		sfx_bounce.play()
	else:
		queue_free()
