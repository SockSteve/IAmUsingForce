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

@onready var shock_scene = preload("res://Weapons/RangedWeapons/LightningBaller/ShockStatus.tscn")  # Scene for the shock
@onready var shock_line_temp = preload("res://Shared/ElectricLine3D.tscn")

var spawn_pos: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var remaining_bounces: int
var shock_time = -1

func _ready():
	remaining_bounces = bounce_count

func _physics_process(delta):
	velocity = linear_velocity * delta
	move_and_slide()

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
	damage.instigator = _owner.get_owner_ref()
	target.apply_damage.emit(damage)


func show_shock_line(enemy):
	var sl =shock_line_temp.instantiate() as ElectricLine3D
	add_child(sl)
	sl.object1 = self
	sl.object2 = enemy
	sl.fleeting = true
	sl.alive_time = .6
