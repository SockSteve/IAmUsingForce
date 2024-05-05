extends CharacterBody3D

enum states {IDLE, WALK}
var current_state: int = states.IDLE

const SPEED = 5.0
const ACCEL = 12.0
const JUMP_VELOCITY = 4.5

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var sleep_timer = $SleepTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var new_target_calculated: bool= false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if current_state == states.IDLE:
		if not new_target_calculated:
			search_new_target()
			new_target_calculated = true
			sleep_timer.start()
		return
	
	if current_state == states.WALK:
		#if global_position.is_equal_approx(nav.target_position):
		if HelperLibrary.custom_approx_equal(global_position,nav.target_position,0.3 ):
			new_target_calculated = false
			current_state = states.IDLE
			return
			
		HelperLibrary.smooth_3d_rotate_towards_vector(self, nav.target_position, 10.0, delta)
		var direction: Vector3 = Vector3()
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction*SPEED, ACCEL*delta)
		move_and_slide()
	#print("my state: ",current_state , "  target: ",nav.target_position, "  my glob_pos: ",global_position, "  my pos: ",position )

func search_new_target():
	await get_tree().process_frame
	var rand_point: Vector3 = HelperLibrary.get_random_point_in_3d_area(self,3,6)
	var target_position = NavigationServer3D.map_get_closest_point(nav.get_navigation_map(), rand_point)
	nav.target_position = target_position

func random_point_on_map():
	var rand_point: Vector3 = HelperLibrary.get_random_point_in_3d_area(self,3,6)
	return NavigationServer3D.map_get_closest_point(nav.get_navigation_map(), rand_point)

func _on_sleep_timer_timeout():
	current_state = states.WALK
