extends CharacterBody3D
class_name GunBullet

var _owner: Weapon
var linear_velocity = Vector3.ZERO

@onready var sfx_bullet_explosion: AudioStreamPlayer3D = $SFXBulletExplosion
@onready var vfx_explosion: Node3D = $VFXExplosion
@onready var bullet_collision: CollisionShape3D = $BulletCollision
@onready var bullet_mesh: MeshInstance3D = $BulletMesh
@onready var enemy_detection_area: Area3D = $EnemyDetectionArea
@onready var hit_box: Area3D = $HitBox

#@spawn_pos is set from parent
var spawn_pos: Vector3 = Vector3.ZERO
var homing_target: Area3D

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


func _on_hit_box_area_entered(area: Area3D) -> void:
	var target = area.get_parent() as EnemyBase
	var damage: Damage = Damage.new()
	damage.value = 25
	damage.source = _owner
	damage.instigator = _owner._owner
	target.apply_damage.emit(damage)
	hit_box.disable_mode = CollisionObject3D.DISABLE_MODE_REMOVE
	on_hit()


func kill_self():
	queue_free()


func _on_enemy_detection_area_area_entered(enemy_hurtbox: Area3D) -> void:
	homing_target = enemy_hurtbox
	enemy_detection_area.set_deferred("monitoring", false)


func activate_homing() -> bool:
	if spawn_pos == Vector3.ZERO or !is_instance_valid(homing_target):
		return false

	var total_distance = spawn_pos.distance_to(homing_target.global_position)
	var current_distance = global_position.distance_to(homing_target.global_position)

	if current_distance < total_distance / 2:
		return true
	return false
