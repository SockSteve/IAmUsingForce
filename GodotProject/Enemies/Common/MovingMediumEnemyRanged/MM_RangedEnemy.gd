extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var bullet : PackedScene
@export var bullet_speed : float = 10.0
@onready var bullet_spawn_point: Marker3D = $TripleGun/BulletSpawnPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func _ready():
	animation_player

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	HelperLibrary.smooth_3d_rotate_towards(self, get_tree().get_first_node_in_group("player"),10.0, delta)
	
	move_and_slide()

func shoot():
	var bullet = bullet.instantiate()
	ObjectContainer.add_child(bullet)
	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = bullet_spawn_point.global_transform.origin
	# Apply velocity to the bullet
	bullet.move($TripleGun.global_basis.z.normalized(), bullet_speed)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		animation_player.play("idle")
		timer.start()

func _on_timer_timeout():
	animation_player.play("attack")
