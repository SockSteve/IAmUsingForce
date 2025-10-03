# Grut.gd - Clean melee enemy using distance/LOS detection
class_name Grut
extends Enemy

@export var bite_hitbox: Hitbox
@export var bite_damage: int = 10
@export var bite_impact_force: float = 5.0
@onready var attack_sfx: AudioStreamPlayer3D = $AttackSFX

func _ready() -> void:
	super._ready()
	add_to_group("enemies")
	
	# Set up default AI config for melee-only enemy
	if ai_config:
		ai_config.attack_type = EnemyAIConfig.AttackType.MELEE
	
	# Set up default stagger config if needed
	if not stagger_config:
		stagger_config = StaggerConfig.new()
		stagger_config.enabled = true
		stagger_config.condition = StaggerConfig.StaggerCondition.DAMAGE_THRESHOLD
		stagger_config.damage_threshold = 5.0
	
	# Connect to animation signals
	animation_player.play("idle")
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

func melee_attack() -> void:
	super.melee_attack()
	
	# Stop movement for attack
	velocity.x = 0
	velocity.z = 0
	
	# Wait for bite animation to reach attack point
	await get_tree().create_timer(0.15).timeout
	
	# Skip damage application if we died or got staggered during the animation
	if is_dead or is_staggered:
		return
	
	# Apply damage to players in bite range
	if is_target_in_melee_range() and current_target and can_see_target:
		_apply_bite_damage()

func _apply_bite_damage():
	var player_hurtbox = current_target.get_node_or_null("Hurtbox")
	if player_hurtbox and player_hurtbox is Hurtbox:
		var damage = Damage.new()
		damage.value = bite_damage
		damage.instigator = self
		damage.impact_point = global_position
		damage.force = bite_impact_force
		
		player_hurtbox.take_damage(damage)
		
		# Play attack sound
		if attack_sfx:
			attack_sfx.play()

func _on_animation_finished(anim_name: String) -> void:
	# Skip if we died or are staggered
	if is_dead or is_staggered:
		return
		
	match anim_name:
		"attack", "melee_attack":
			var state_machine = get_node_or_null("StateMachine")
			if state_machine and state_machine is EnemyStateMachine:
				if is_target_in_melee_range() and current_target and can_see_target:
					# Stay in attack state to bite again
					state_machine.change_state("MeleeAttack")
				else:
					# Chase if target moved away or lost sight
					state_machine.change_state("Chase")
		
		"stagger", "damage":
			if animation_player:
				var state_machine = get_node_or_null("StateMachine")
				if state_machine and state_machine is EnemyStateMachine and state_machine.current_state:
					match state_machine.current_state.name:
						"Idle":
							play_animation("idle")
						"Chase", "ReturnToOrigin":
							play_animation("walk")
						"MeleeAttack":
							# The attack state will handle its own animations
							pass
