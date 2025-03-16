extends Node
class_name XpReward

@export var xp_reward_hit: int = 0
@export var xp_reward_death: int = 0
@export var hp_component: Hp

func _ready() -> void:
	if not hp_component:
		return
	hp_component.hp_chaged.connect(give_reward)

func give_reward(target: Weapon, death: bool = false):
	if not target:
		return
	
	if xp_reward_hit > 0:
		target.add_xp(xp_reward_hit)
	
	if death and xp_reward_death > 0:
		target.add_xp(xp_reward_death)
