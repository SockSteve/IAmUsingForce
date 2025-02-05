extends RayCast3D

@onready var vfx_explosion: VFXExplosion = $VFXExplosion
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var impact_sfx: AudioStreamPlayer3D = $ImpactSfx

var _owner: Weapon
var linear_velocity = Vector3.ZERO
var pellet_hit: bool = false

var uptime:= 0.0
var life_time:= .6

func _ready() -> void:
	vfx_explosion.explosion_finished.connect(kill_self)

func _physics_process(delta):
	if uptime >= life_time:
		queue_free()
	uptime += delta
	
	# Move the bullet
	translate(linear_velocity * delta)
	if collide_with_areas:
		if get_collider() == null:
			return
		hit(get_collider())

func hit(collision_object: Area3D):
	#explosion_finished
	
	pellet_hit = true
	vfx_explosion.emit_explosion()
	if collision_object.is_in_group('damageable'):
		if _owner.enemies_hit.has(collision_object.get_parent()):
			pass
		apply_damage(collision_object.get_parent())
	
func apply_damage(target):
	var damage: Damage = Damage.new()
	damage.value = 25
	damage.source = _owner
	damage.instigator = _owner.get_owner_ref()
	target.apply_damage.emit(damage)

func kill_self():
	queue_free()
	pass

func _on_gpu_particles_3d_finished():
	if pellet_hit:
		gpu_particles_3d.visible = false
		return
	queue_free()
