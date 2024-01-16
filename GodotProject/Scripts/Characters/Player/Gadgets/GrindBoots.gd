extends PathFollow3D

@onready var player = find_parent("Player")
@onready var shapeCast: ShapeCast3D = $ShapeCast3D
var grind_path: Path3D = null
var canGrind: bool = true 

func _ready():
	shapeCast.add_exception(player)
	
func _physics_process(delta):
	if shapeCast.is_colliding():
		print(shapeCast.get_collider(0))

func on_grindrail_entered(body):
	print(body.is_in_group("grindRail"))
	if body.is_in_group("grindRail") and canGrind:
		player._currentGrindRail = body
		player.grinding = true
		canGrind = false

func end_grind():
	player._currentGrindRail = null
	player.grinding = false
	$GrindEndCooldown.start()

func _on_grind_end_cooldown_timeout():
	canGrind = true
