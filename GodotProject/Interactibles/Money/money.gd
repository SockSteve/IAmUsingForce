extends RigidBody3D
class_name Money

const MIN_LAUNCH_RANGE := 2.0
const MAX_LAUNCH_RANGE := 4.0
const MIN_LAUNCH_HEIGHT := 1.0
const MAX_LAUNCH_HEIGHT := 3.0

@onready var money_mesh: MeshInstance3D = $MoneyMesh
@onready var money_collision: CollisionShape3D = $MoneyCollision
#@onready var _collect_audio: AudioStreamPlayer3D = $CollectAudio

@export var value_small: int = 10  # Value of the clump (gold/silver)
@export var value_big: int = 50  # Value of the clump (gold/silver)
@export var big: bool = false
@export var attraction_speed: float = 5.0  # Speed of attraction to the player

var physics_active: bool = true
var attracted_to_player: bool = false
var player: Node = null
var gold_value = value_small #final value

func spawn(coin_delay: float = 0.5) -> void:
	var rand_height := MIN_LAUNCH_HEIGHT + (randf() * MAX_LAUNCH_HEIGHT)
	var rand_dir := Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI)
	var rand_pos := rand_dir * (MIN_LAUNCH_RANGE + (randf() * MAX_LAUNCH_RANGE))
	rand_pos.y = rand_height
	apply_central_impulse(rand_pos)

func _ready():
	change_size(big)
	# Randomize initial velocity for falling and scattering
	
	spawn()


func change_size(is_big: bool):
	if not is_big:
		gold_value = value_small
		return
	gold_value = value_big
	money_mesh.scale *= 2 
	money_collision.shape.size *= 2


func _physics_process(delta):
	if physics_active:
		if attracted_to_player and player:
			# Move toward the player manually
			look_at(player.global_position)
			var direction = (player.global_transform.origin - global_transform.origin).normalized()
			attraction_speed += delta
			global_transform.origin += direction * attraction_speed * delta
			global_position.y += 1


func player_detected(attractive_player: Player):
	PhysicsServer3D.body_add_collision_exception(get_rid(), attractive_player.get_rid())
	if player:
		sleeping = true
		freeze = true
		return
	physics_active = true
	attracted_to_player = true
	player = attractive_player


func _on_player_collision(player_hurtbox: Node):
	# Handle collection when colliding with the player
	player.get_inventory().add_money(gold_value)  # Assuming the player script has an `add_gold` method
	queue_free()  # Remove the clump


func collect():
	#_collect_audio.pitch_scale = randfn(1.0, 0.1)
	#_collect_audio.play()
	hide()
	player.get_inventory().add_money(gold_value)
	#await _collect_audio.finished
	queue_free()
