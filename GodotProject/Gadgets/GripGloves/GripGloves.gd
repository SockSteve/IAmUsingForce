#this gadget let's you use monkey bars and hang along certein ceilings
extends Gadget
class_name GripGloves

@onready var grip_cast: RayCast3D = $RayCast3D
@onready var release_timer: Timer = $ReleaseTimer
@onready var player: Player = find_parent("Player")

#TODO
func _physics_process(_delta):
	if not grip_cast.is_colliding():
		player.is_monkey_bar = false
		return
		
	if not grip_cast.get_collider().is_in_group("monkey_bar"):
		return
	
	player.is_monkey_bar = true
	
	if Input.is_action_just_pressed("interact"):
		set_physics_process(false)
		release_timer.start()
		player.is_monkey_bar = false
	return
	
func get_collision_normal()->Vector3:
	return grip_cast.get_collision_normal()


func _on_release_timer_timeout():
	set_physics_process(true)
