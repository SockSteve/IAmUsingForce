extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var target: Player = null

@onready var hitbox: Area3D = $MeleeWeaponArea
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if target != null:
		HelperLibrary.smooth_3d_rotate_towards(self, target,10.0, delta)
	
	move_and_slide()
	
func activate_hitbox():
	hitbox.monitoring = true
	timer.start()

func _on_timer_timeout():
	hitbox.monitoring = false

func _on_melee_weapon_area_body_entered(body):
	if body.is_in_group("player"):
		print("you've been hit by ", self)

func _on_player_detection_area_player_entered(player):
	target = player

func _on_player_detection_area_player_exited(player):
	target = null

func _on_player_detection_area_player_entered_attack_range(player):
	animation_player.play("attack")

func _on_player_detection_area_player_exited_attack_range(player):
	animation_player.play("idle")
