extends CharacterBody3D
class_name GunBullet

@export var bullet_stats: BulletStats
var linear_velocity = Vector3.ZERO
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready():
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	# Move the bullet
	velocity = linear_velocity * delta
	#translate(linear_velocity * delta)
	move_and_slide()
	if get_slide_collision_count() > 0:
		if get_last_slide_collision().get_collider(0).is_in_group("enemy"):
			get_last_slide_collision().get_collider(0).apply_damage(bullet_stats)
		queue_free()
