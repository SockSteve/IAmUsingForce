extends PathFollow3D

var id = "g00"

@onready var player: Player = find_parent("Player")
@onready var shapeCast: ShapeCast3D = $ShapeCast3D
var grind_path: Path3D = null
var canGrind: bool = true
var currentGrindrail = null
var grinding: bool = false 

#at the start, we minimize the results array that contains the
#intersection point data from the shapecast3D
#and we add the player to the exception list
func _ready():
	shapeCast.set_max_results(6)
	shapeCast.add_exception(player)

#here we implemented the logic for when a grindrail was detected and the player
#should start grinding
# note that the movement logic lives in the player intern state machine
func _physics_process(delta):
	if shapeCast.is_colliding():
		if shapeCast.get_collider(0).is_in_group("grindRail") and canGrind:
			canGrind = false
			currentGrindrail = shapeCast.get_collider(0).get_child(0)
			grinding = true

#this function gets called by the state machine
func end_grind():
	currentGrindrail.remove_child(self)
	player.add_gadget(self)
	currentGrindrail = null
	grinding = false
	
	$GrindEndCooldown.start()

#this timer exists so the player doesn't immediately start to grind again after
#getting off the grindrail
func _on_grind_end_cooldown_timeout():
	canGrind = true
