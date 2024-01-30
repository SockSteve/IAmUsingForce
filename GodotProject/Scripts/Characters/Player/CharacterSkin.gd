#class_name CharacterSkin
extends Node3D

signal foot_step

@export var main_animation_player : AnimationPlayer

var moving_blend_path := "parameters/sm_normal/move/blend_position"
var transition_state_mashine_request := "parameters/transition/transition_request"
# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed
@onready var animation_tree : AnimationTree = $AnimationTree

#@onready var transition_state_mashine_request: AnimationNodeTransition = animation_tree.get("parameters/transition/transition_request")
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_normal/playback")
@onready var sm_crouch : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_crouch/playback")
@onready var sm_grind : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grind/playback")
@onready var sm_grapple : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grind/playback")
@onready var sm_melee : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grind/playback")


func _ready():
	pass
	animation_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1


func set_moving(value : bool):
	moving = value
	if moving:
		state_machine.travel("move")
	else:
		state_machine.travel("idle")


func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)


func jump():
	state_machine.travel("jumpstart")


func fall():
	state_machine.travel("fall")

func crouch():
	animation_tree.set(transition_state_mashine_request, "state_crouch")
	sm_crouch.travel("idle")

func uncrouch():
	pass
	
func punch():
	animation_tree["parameters/PunchOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


