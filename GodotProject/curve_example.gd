extends CharacterBody3D

@export var cur: Curve = Curve.new()
@export var factor: float = 1
@export var time_factor = 1.0
var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * time_factor
	velocity.x = cur.sample(time)*factor 
	#velocity.z = cur.sample(time)*factor 
	print(velocity)
	clamp(time,0,1)
	if time >= 1:
		time = 0
		position = Vector3.ZERO
	
	move_and_slide()
