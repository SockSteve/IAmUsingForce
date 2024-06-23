class_name CharacterSkin
extends Node3D

signal foot_step

@export var main_animation_player : AnimationPlayer

#paths to set the moving blend
var moving_blend_path := "parameters/sm_normal/move/blend_position"
var crouch_moving_blend_path := "parameters/sm_crouch/move/blend_position"
#paths to the transitions. they determine what animation sets for wat states are currently in use
var state_transition_request := "parameters/state_transition/transition_request"
var weapon_melee_transition_request := "parameters/weapon_melee_transition/transition_request"
var arm_transition_request := "parameters/armtransition/transition_request"

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle. used for walking and crouching.
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed
@onready var animation_tree : AnimationTree = $AnimationTree

#variables to access the statemachines for the individual states. used to get to the animations inside the states
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_normal/playback")
@onready var sm_melee_cutter : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_melee_cutter/playback")
@onready var sm_onwall : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_onwall/playback")
@onready var sm_ledgehanging : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_ledgehanging/playback")
@onready var sm_takedamage : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_takedamage/playback")
@onready var sm_crouch : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_crouch/playback")
@onready var sm_grind : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grind/playback")
@onready var sm_grapple : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_grapple/playback")
@onready var sm_monkeybar : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_monkeybar/playback")
#state machine for holding weapons
@onready var sm_armtransitions : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/sm_normal/playback")

func _ready():
	pass
	animation_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1

#is used in the walking and crouching state
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
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("jumpstart")

func fall():
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("falling")

func crouch():
	animation_tree.set(state_transition_request, "state_crouch")
	sm_crouch.travel("idle")

func grind():
	animation_tree.set(state_transition_request, "state_grind")
	sm_grind.travel("idle")

func end_grind():
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

func slide():
	animation_tree.set(state_transition_request, "state_crouch")
	sm_crouch.travel("slide")

func uncrouch():
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

func change_weapon(weapon:StringName):
	animation_tree.set(arm_transition_request, weapon.to_lower())

func attack(attack_counter:int, weapon_name: StringName = "cutter"):
	animation_tree.set(state_transition_request, "state_melee")
	animation_tree.set(weapon_melee_transition_request, "melee_cutter")
	var current_attack_animation = "attack_" + str(attack_counter)
	sm_melee_cutter.travel(current_attack_animation)

func air_attack(up_or_down: StringName):
	animation_tree.set(state_transition_request, "state_melee")
	animation_tree.set(weapon_melee_transition_request, "melee_cutter")
	var current_attack_animation = up_or_down + "_air_attack"
	sm_melee_cutter.travel(current_attack_animation)

func block():
	animation_tree.set(state_transition_request, "state_melee_cutter")
	sm_melee_cutter.travel("parry")

func return_to_normal():
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

func grapple():
	animation_tree.set(state_transition_request, "state_grapple")
	sm_grapple.travel("mixamograpple_grapplestart")

func monkey_bar():
	printerr("MONKEYBARS ANIMATION NOT IMPLEMENTED YET!")
	#animation_tree.set(state_transition_request, "sm_monkeybar")
	#sm_grapple.travel("idle")

func take_damage():
	animation_tree.set(state_transition_request, "sm_takedamage")
	animation_tree.set(state_transition_request, "mixamomisc_takedamage")
