extends MeshInstance3D

@export var shock_line: MeshInstance3D = self
@export var shock_radius: float = 5.0
@export var shock_duration: float = 2

var is_shocking: bool = false
var shock_timer: float = 0.0
var target_enemy: Node3D = null

func init_line(enemy):
	start_shock(enemy)

func _process(delta):
	if is_shocking:
		shock_timer += delta
		if shock_timer >= shock_duration:
			stop_shock()
		else:
			update_shock_line()

func start_shock(enemy: Node3D):
	if not is_shocking:
		is_shocking = true
		shock_timer = 0.0
		target_enemy = enemy
		shock_line.visible = true

func stop_shock():
	is_shocking = false
	shock_line.visible = false
	target_enemy = null

func update_shock_line():
	if target_enemy:
		# Calculate the direction and distance to the enemy
		var direction = target_enemy.global_transform.origin - global_transform.origin
		var distance = direction.length()

		# Position the line halfway between the bullet and the enemy
		shock_line.global_transform.origin = global_transform.origin + direction * 0.5

		# Rotate the line to face the enemy
		shock_line.look_at(target_enemy.global_transform.origin)
		shock_line.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90)) # Adjust rotation for a quad/cylinder

		# Scale the line to match the distance
		shock_line.scale.y = distance
