#class_name CharacterSkin
extends Node3D

signal foot_step

@export var main_animation_player : AnimationPlayer

var moving_blend_path := "parameters/sm_normal/move/blend_position"
var crouch_moving_blend_path := "parameters/sm_crouch/move/blend_position"
var transition_state_mashine_request := "parameters/transition/transition_request"
var arm_transition_state_mashine_request := "parameters/armtransition/transition_request"
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
@onready var sm_grapple : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grapple/playback")
@onready var sm_melee : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_melee/playback")
@onready var sm_armtransitions : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_normal/playback")

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

func set_crouch_moving(value : bool):
	moving = value
	if moving:
		sm_crouch.travel("move")
	else:
		sm_crouch.travel("idle")

func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)

func set_crouch_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(crouch_moving_blend_path, move_speed)

func jump():
	state_machine.travel("jumpstart")

func fall():
	state_machine.travel("fall")

func crouch():
	animation_tree.set(transition_state_mashine_request, "state_crouch")
	sm_crouch.travel("idle")

func grind():
	animation_tree.set(transition_state_mashine_request, "state_grind")
	sm_grind.travel("idle")

func end_grind():
	animation_tree.set(transition_state_mashine_request, "state_normal")
	state_machine.travel("idle")

func slide():
	animation_tree.set(transition_state_mashine_request, "state_crouch")
	sm_crouch.travel("slide")

func uncrouch():
	animation_tree.set(transition_state_mashine_request, "state_normal")
	state_machine.travel("idle")

func change_weapon(weapon:StringName):
	animation_tree.set(arm_transition_state_mashine_request, weapon.to_lower())

func attack(attack_counter):
	animation_tree.set(transition_state_mashine_request, "state_melee")
	var current_attack_animation = "attack_" + str(attack_counter)
	sm_melee.travel(current_attack_animation)
	#sm_melee.travel("attack_1")

func block():
	animation_tree.set(transition_state_mashine_request, "state_melee")
	sm_melee.travel("parry")
	#animation_tree["parameters/PunchOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

