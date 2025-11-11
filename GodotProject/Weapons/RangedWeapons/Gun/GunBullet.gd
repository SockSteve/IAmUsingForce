extends CharacterBody3D
class_name GunBullet

var _owner: Weapon
var linear_velocity = Vector3.ZERO

@onready var sfx_bullet_explosion: AudioStreamPlayer3D = $SFXBulletExplosion
@onready var vfx_explosion: Node3D = $VFXExplosion
@onready var bullet_collision: CollisionShape3D = $BulletCollision
@onready var bullet_mesh: MeshInstance3D = $BulletMesh

@onready var hurtbox_detection_area_3d: HurtboxDetectionArea3D = $HurtboxDetectionArea3D
@onready var hit_box: Area3D = $Hitbox

#set from parent (weapon who shoots the bullet)
var damage: Damage

var homing_target: Marker3D

func _ready():
	vfx_explosion.explosion_finished.connect(kill_self)
	await get_tree().create_timer(5.0).timeout
	queue_free()


func _physics_process(delta):
	if activate_homing():
		var direction_to_target = (homing_target.global_position - global_position).normalized()

		var steering_strength = 8.0  # Adjust this to control how quickly the bullet homes in
		linear_velocity = linear_velocity.lerp(direction_to_target * linear_velocity.length(), steering_strength * delta)

	velocity = linear_velocity * delta
	move_and_slide()

	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		on_hit(collision)


func on_hit(collision: KinematicCollision3D = null):
	# Check if we hit a ShootableTarget
	if collision:
		var collider = collision.get_collider()
		if collider and collider.has_method("on_bullet_hit"):
			var hit_position = collision.get_position()
			var hit_normal = collision.get_normal()
			collider.on_bullet_hit(self, hit_position, hit_normal)

	sfx_bullet_explosion.play()
	bullet_collision.disabled = true
	bullet_mesh.visible = false
	vfx_explosion.emit_explosion()


func kill_self():
	queue_free()

func activate_homing() -> bool:
	if !is_instance_valid(homing_target):
		return false

	return true

func _on_hurtbox_detection_area_3d_area_entered(enemy_hurtbox: Area3D) -> void:
	print("enemy detected")
	await get_tree().process_frame
	if not enemy_hurtbox:
		return
		
	homing_target = hurtbox_detection_area_3d.get_closest_area().attraction_point
	hurtbox_detection_area_3d.queue_free()
	activate_homing()


func _on_hitbox_area_entered(hurtbox: Hurtbox) -> void:
	var target = hurtbox.attraction_point
	print("deal damage")
	
	damage.impact_point = (global_position - hurtbox.attraction_point.global_position).normalized()
	damage.force = -1.5
	hurtbox.take_damage(damage)
	on_hit()
