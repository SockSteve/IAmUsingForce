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

var spawn_pos: Vector3 = Vector3.ZERO
var homing_target: Marker3D

func _ready():
	vfx_explosion.explosion_finished.connect(kill_self)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _enter_tree() -> void:
	spawn_pos = global_position

func _physics_process(delta):
	if activate_homing():
		var direction_to_target = (homing_target.global_position - global_position).normalized()

		var steering_strength = 5.0  # Adjust this to control how quickly the bullet homes in
		linear_velocity = linear_velocity.lerp(direction_to_target * linear_velocity.length(), steering_strength * delta)
	
	velocity = linear_velocity * delta
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		on_hit()


func on_hit():
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
	homing_target = hurtbox_detection_area_3d.get_closest_area().attraction_point
	hurtbox_detection_area_3d.queue_free()
	activate_homing()


func _on_hitbox_area_entered(hurtbox: Area3D) -> void:
	var target = hurtbox.attraction_point
	print("deal damage")
	hurtbox.take_damage(damage)
	on_hit()
