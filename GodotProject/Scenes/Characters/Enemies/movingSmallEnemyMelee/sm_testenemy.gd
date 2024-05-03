extends CharacterBody3D

@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var lingering_hitbox_timer = $AttackHitbox/LingeringHitboxTimer
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player = $AnimationPlayer

const SPEED = 5.0
const ACCEL = 10.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null

func _ready():
	animation_player.animation_finished.connect(end_attack.bind())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction: Vector3 = Vector3()
	if player != null and animation_player.current_animation != "attack":
		HelperLibrary.smooth_3d_rotate_towards(self, player, 10.0, delta)
		nav.target_position = player.global_position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction*SPEED, ACCEL*delta)
	
	else:
		velocity = Vector3.ZERO
		if not is_on_floor():
			velocity.y -= gravity * delta

	move_and_slide()

func start_attack():
	animation_player.play("attack")

func attack():
	attack_hitbox.monitoring = true
	lingering_hitbox_timer.start()

func _on_lingering_hitbox_timer_timeout():
	attack_hitbox.monitoring = false

func _on_attack_hitbox_body_entered(body: Node):
	if body.is_in_group("player"):
		print("ouch")

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player = null

func _on_init_attack_area_body_entered(body):
	start_attack()

func end_attack(anim_name):
	if anim_name == "attack":
		animation_player.play("idle")
