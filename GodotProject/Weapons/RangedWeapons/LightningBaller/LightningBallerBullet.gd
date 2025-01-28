extends CharacterBody3D

var _owner: Weapon
var linear_velocity = Vector3.ZERO

@export var speed: float = 40.0
@export var bounce_count: int = 3  # How many times the bullet can bounce
@export var shock_radius: float = 5.0
@export var shock_damage: float = 10.0
@export var lightning_damage: float = 50.0

@onready var sfx_explode: AudioStreamPlayer3D = $SFXExplode
@onready var sfx_shock: AudioStreamPlayer3D = $SFXShock
@onready var sfx_bounce: AudioStreamPlayer3D = $SFXBounce

@onready var shock_line: MeshInstance3D = %ElectricArc
@onready var shock_scene = preload("res://Weapons/RangedWeapons/ShockStatus.tscn")  # Scene for the shock

var spawn_pos: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var remaining_bounces: int
var shock_time = -1

func _ready():
	remaining_bounces = bounce_count

func _physics_process(delta):
	velocity = linear_velocity * delta
	move_and_slide()

	if shock_time < 0:
		return
	shock_time += delta
	if shock_time > .33:
		shock_line.visible = false
	# Check collisions
	#if get_slide_collision_count() > 0:
		#handle_collision(get_slide_collision(0))

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
	sfx_shock.play()
	show_shock_line(enemy)
	var shock_instance = shock_scene.instantiate()
	shock_instance.setup(enemy, shock_radius, shock_damage)
	enemy.add_child(shock_instance)  # Attach the shock to the enemy

func bounce(normal: Vector3):
	if remaining_bounces > 0:
		direction = direction.bounce(normal).normalized()
		remaining_bounces -= 1
		sfx_bounce.play()
	else:
		queue_free()

func _on_shock_area_area_entered(area: Area3D) -> void:
	var target = area.get_parent() as EnemyBase
	show_shock_line(target)
	shock_enemy(target)
	var damage: Damage = Damage.new()
	damage.value = 25
	damage.source = _owner
	damage.instigator = _owner._owner
	target.apply_damage.emit(damage)


func show_shock_line(enemy):
	# Calculate the distance and direction to the enemy
	var direction_to_enemy = (enemy.global_position - global_position).normalized()
	var distance = global_position.distance_to(enemy.global_position)

	# Position and scale the shock line (cylinder) to connect the bullet and enemy
	shock_line.visible = true
	shock_line.global_transform.origin = global_position + (direction_to_enemy * (distance / 2))
	shock_line.scale = Vector3((distance / 2), (distance / 2), (distance / 2))  # Adjust the radius and height
	shock_line.look_at(enemy.global_position,Vector3.UP,true)

	shock_time = 0
