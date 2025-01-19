class_name Bullet3DWithServer
extends MeshInstance3D

const SHAPE := preload("res://Enemies/Common/StationaryTurret/StationaryTurretBulletCollisionShape.tres")

var query = PhysicsShapeQueryParameters3D.new()
@onready var direct_space_state := get_world_3d().direct_space_state

@export var max_fly_distance := 1200.0
@export var time_to_live := 10.0 
var _speed := 0 
var linear_velocity

var traveled_distance := 0.0
# Called when the node enters the scene tree for the first time.

func _init()->void:
	query.set_shape(SHAPE)
	query.collide_with_bodies = true
	query.set_collision_mask(1)
	top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance = _speed * delta
	translate(linear_velocity * delta)
	traveled_distance += distance
	query.transform = global_transform
	
	var result := direct_space_state.intersect_shape(query,1)
	if result: 
		queue_free()

func move(direction: Vector3, speed: float):
	linear_velocity = direction * speed
	_speed = speed
