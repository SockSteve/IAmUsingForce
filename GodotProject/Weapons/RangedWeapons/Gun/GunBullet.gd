extends CharacterBody3D
class_name GunBullet

var _owner: Weapon
var linear_velocity = Vector3.ZERO

@onready var sfx_bullet_explosion: AudioStreamPlayer3D = $SFXBulletExplosion
@onready var vfx_explosion: Node3D = $VFXExplosion
@onready var bullet_collision: CollisionShape3D = $BulletCollision
@onready var bullet_mesh: MeshInstance3D = $BulletMesh


func _ready():
	await get_tree().create_timer(5.0).timeout
	queue_free()


func _physics_process(delta):
	# Move the bullet
	velocity = linear_velocity * delta
	move_and_slide()
	if get_slide_collision_count() > 0:
		if get_last_slide_collision().get_collider(0).is_in_group("enemy"):
			get_last_slide_collision().get_collider(0).apply_damage(_owner.weapon_stats.get_damage())
		on_hit()


func on_hit():
	sfx_bullet_explosion.play()
	bullet_collision.disabled = true
	bullet_mesh.visible = false
	vfx_explosion.emit_explosion()
	await vfx_explosion.smoke.finished
	queue_free()
	
