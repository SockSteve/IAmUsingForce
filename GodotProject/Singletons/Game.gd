extends Node

var current_level: Node3D
var players: Array[Node3D] = []
var enemies: Array[Enemy] = []

# Spatial optimization - divide world into chunks
var world_chunks: Dictionary = {}
var chunk_size: float = 50.0

func _ready():
	# Update every 100ms instead of every frame
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_update_enemy_detection)
	timer.autostart = true
	add_child(timer)

func register_player(player: Node3D):
	players.append(player)

func unregister_player(player: Node3D):
	players.erase(player)

func register_enemy(enemy: Enemy):
	enemies.append(enemy)

func unregister_enemy(enemy: Enemy):
	enemies.erase(enemy)

func _update_enemy_detection():
	if players.is_empty():
		return
	
	# Batch process all enemies
	for enemy: Enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var closest_player = _find_closest_player_in_range(enemy)
		enemy._on_detection_update(closest_player)

func _find_closest_player_in_range(enemy: Enemy) -> Node3D:
	var closest_player: Node3D = null
	var closest_distance_squared: float = INF
	var enemy_pos = enemy.global_position
	var range_squared = enemy.detection_range * enemy.detection_range
	
	for player in players:
		if not is_instance_valid(player):
			continue
			
		var distance_squared = enemy_pos.distance_squared_to(player.global_position)
		
		if distance_squared <= range_squared and distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_player = player
	
	return closest_player

# Level management
func load_level(level_scene: PackedScene):
	if current_level:
		_cleanup_current_level()
	
	current_level = level_scene.instantiate()
	get_tree().current_scene.add_child(current_level)
	
	# Auto-register players and enemies in the new level
	_auto_register_entities()

func _cleanup_current_level():
	players.clear()
	enemies.clear()
	if current_level:
		current_level.queue_free()

func _auto_register_entities():
	# Auto-find and register players
	for player in get_tree().get_nodes_in_group("players"):
		register_player(player)
	
	# Auto-find and register enemies  
	for enemy in get_tree().get_nodes_in_group("enemies"):
		register_enemy(enemy)
