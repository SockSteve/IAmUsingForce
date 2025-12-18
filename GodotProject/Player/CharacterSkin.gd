class_name CharacterSkin
extends Node3D

## Manages all character animations and visual feedback for the player
## Interfaces with movement states, combat system, and weapon changes

signal foot_step
signal attack_hitbox_state_change(hitbox_state: bool)
signal lock_player(lock_state: bool)

@onready var general_skeleton: Skeleton3D = %GeneralSkeleton
@export var main_animation_player: AnimationPlayer

#paths to set the moving blend
var moving_blend_path := "parameters/sm_normal/move/blend_position"
var crouch_moving_blend_path := "parameters/sm_crouch/move/blend_position"
var ranged_weapon_grip_blend_path := "parameters/weapon_grip_blend/blend_amount"

#paths to the transitions. they determine what animation sets for wat states are currently in use
var state_transition_request := "parameters/state_transition/transition_request"
var weapon_melee_transition_request := "parameters/weapon_melee_transition/transition_request"
var arm_transition_request := "parameters/armtransition/transition_request"

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving
@onready var right_hand: Node3D = %RightWeaponSocket
@onready var left_hand: Node3D = %LeftWeaponSocket
@onready var back: Node3D = %BackSocket


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

#@onready var left_arm_ik: GodotIK = $GeneralSkeleton/LeftArm
#@onready var right_arm_ik: GodotIK = $GeneralSkeleton/RightArm
@onready var grapple_physics: PhysicalBoneSimulator3D = $GeneralSkeleton/GrapplePhysics


func _ready() -> void:
	animation_tree.active = true
	if main_animation_player:
		main_animation_player["playback_default_blend_time"] = 0.1

# ============================================================================
# MOVEMENT ANIMATIONS
# ============================================================================

## Set whether character is moving (used in walking and running states)
func set_moving(value: bool) -> void:
	moving = value
	if moving:
		state_machine.travel("move")
	else:
		state_machine.travel("idle")

## Set whether character is moving while crouched
func set_crouch_moving(value: bool) -> void:
	moving = value
	if moving:
		sm_crouch.travel("move")
	else:
		sm_crouch.travel("idle")

## Set movement speed blend (0.0 = walk, 1.0 = run)
func set_moving_speed(value: float) -> void:
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)

## Set crouch movement speed blend
func set_crouch_moving_speed(value: float) -> void:
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(crouch_moving_blend_path, move_speed)

## Play jump animation
func jump() -> void:
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("jumpstart")

## Play falling animation
func fall() -> void:
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("falling")

## Enter crouch state
func crouch() -> void:
	animation_tree.set(state_transition_request, "state_crouch")
	sm_crouch.travel("idle")

## Exit crouch state
func uncrouch() -> void:
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

## Play slide animation
func slide() -> void:
	animation_tree.set(state_transition_request, "state_crouch")
	sm_crouch.travel("slide")

# ============================================================================
# PARKOUR ANIMATIONS
# ============================================================================

## Enter grind state
func grind() -> void:
	animation_tree.set(state_transition_request, "state_grind")
	sm_grind.travel("idle")

## Exit grind state
func end_grind() -> void:
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

## Enter grapple state
func grapple() -> void:
	animation_tree.set(state_transition_request, "state_grapple")
	sm_grapple.travel("mixamograpple_hanginggrapple")

## Grab ledge animation
func grab_ledge() -> void:
	animation_tree.set(state_transition_request, "state_ledgehanging")
	sm_ledgehanging.travel("idle")

## Monkey bar animation (not yet implemented)
func monkey_bar() -> void:
	printerr("MONKEYBARS ANIMATION NOT IMPLEMENTED YET!")
	#animation_tree.set(state_transition_request, "sm_monkeybar")
	#sm_grapple.travel("idle")

# ============================================================================
# WEAPON & COMBAT ANIMATIONS
# ============================================================================

## Change weapon animations based on weapon type
func change_weapon(weapon: StringName, groups: Array[StringName]) -> void:
	if groups.has("melee"):
		animation_tree.set(ranged_weapon_grip_blend_path, 0)
	else:
		animation_tree.set(ranged_weapon_grip_blend_path, 1)
		animation_tree.set(arm_transition_request, weapon.to_lower())
		await animation_tree.animation_finished
		# Setup IK target for ranged weapon
		#if left_arm_ik:
			#var ik_target = left_arm_ik.find_child("LH_" + weapon.to_pascal_case())
			#if ik_target:
				#print("CharacterSkin: IK target found for ", weapon)

## Play melee attack animation
func attack(attack_counter: int, weapon_name: StringName = "cutter") -> void:
	animation_tree.set(state_transition_request, "state_melee")
	animation_tree.set(weapon_melee_transition_request, "melee_" + weapon_name)
	var current_attack_animation = "attack_" + str(attack_counter)
	sm_melee_cutter.travel(current_attack_animation)

## Play air attack animation
func air_attack(up_or_down: StringName) -> void:
	animation_tree.set(state_transition_request, "state_melee")
	animation_tree.set(weapon_melee_transition_request, "melee_cutter")
	var current_attack_animation = up_or_down + "_air_attack"
	sm_melee_cutter.travel(current_attack_animation)

## Play block/parry animation
func block() -> void:
	animation_tree.set(state_transition_request, "state_melee_cutter")
	sm_melee_cutter.travel("parry")

## Return to normal idle state
func return_to_normal() -> void:
	animation_tree.set(state_transition_request, "state_normal")
	state_machine.travel("idle")

## Play take damage animation
func take_damage() -> void:
	animation_tree.set(state_transition_request, "sm_takedamage")
	animation_tree.set(state_transition_request, "mixamomisc_takedamage")
