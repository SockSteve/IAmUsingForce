extends CharacterBody3D

@onready var sword_pivot: Marker3D = $BladePivot
@onready var bullet_spawn_point: Marker3D = $Bazooka/BulletSpawnPoint
@onready var blade: PackedScene = preload("res://Enemies/BigEnemyMeleeRanged/BladeHitDetectionArea.tscn")
@onready var timer: Timer = $Timer

@export var bullet: PackedScene
@export var bullet_speed = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var orbit_radius : float = 1.0  # Radius of the orbit
var orbit_speed : float = 1.0   # Speed of orbit
var swords : Array = []
var _player: Player = null
var player_is_in_melee_range: bool = false
var player_seen = false

func _ready():
	create_swords(8)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if _player != null:
		HelperLibrary.smooth_3d_rotate_towards(self, _player,10.0, delta)
		if not player_is_in_melee_range:
			$BladePivot.visible = false
			$Bazooka.look_at(_player.global_position)
		else:
			$BladePivot.visible = true
		
	move_and_slide()
	sword_pivot.rotation.y += delta * 5

func _on_alert_to_player_area_3d_player_entered(player):
	_player = player
	player_seen=true
	timer.start()

func _on_alert_to_player_area_3d_player_entered_attack_range(player):
	_player = player
	player_is_in_melee_range = true
	timer.stop()


func _on_alert_to_player_area_3d_player_exited_attack_range(player):
	_player = player
	player_is_in_melee_range = false
	timer.start()

func _on_alert_to_player_area_3d_player_exited(player):
	_player = null
	timer.stop()
	if _player == null:
		player_seen=false

func create_swords(num_swords):
	# Create moons evenly distributed around the Earth
	for i in range(num_swords):
		#var angle = (i / num_swords) * 360  # Calculate angle for even distribution
		var angle = deg_to_rad(360 / num_swords * i) #alias 2 pi
		var sword_position = Vector3(cos(angle), 0, sin(angle))
		
		# Create moon instance and add to scene
		var blade_instance: Area3D = blade.instantiate() # Load moon scene
		sword_pivot.add_child(blade_instance)  # Add moon to the scene
		blade_instance.connect("body_entered", apply_damage)
		blade_instance.rotation.y = angle  # Set moon position
		swords.append(blade_instance)  # Store moon reference

func shoot():
	var bullet = bullet.instantiate()
	BulletContainer.add_child(bullet)
	# Set the bullet's position to the gun's position
	bullet.global_transform.origin = bullet_spawn_point.global_transform.origin
	# Apply velocity to the bullet
	bullet.move($Bazooka.global_basis.z.normalized() * -1, bullet_speed)

func apply_damage(body):
	if body.is_in_group("player"):
		print("aaaaaaaaaaiiiiiiiiiiiiieeeeeeeeeeee")


func _on_timer_timeout():
	shoot()
