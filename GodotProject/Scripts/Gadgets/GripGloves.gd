#this gadget let's you use monkey bars and hang along certein ceilings
extends Gadget
class_name GripGloves

@onready var grip_cast: RayCast3D = $RayCast3D

#TODO
func _physics_process(delta):
	if not grip_cast.is_colliding():
		return
		
	if not grip_cast.get_collider().is_in_group("monkey_bar"):
		return
	
	grip_cast.get_collision_normal()
