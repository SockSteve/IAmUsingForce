extends Resource
class_name EnemyStats


signal poise_broken
signal defeat
signal knockback(amount: float)


## max health of an enemy
@export var max_health: int
## enemy staggers when poise hits 0. This value should be smaller than max_health
@export var max_poise: int
## when retaliate = true -> enemy attacks after stagger, this attack cannot be
## interrupted and only after the attack does the enemy take poise damage again
@export var force_retaliate: bool


# current enemy health and poise
var health: int
var poise: int


func take_damage(damage: int, stagger: int = 0, knockback: int = 0) -> void:
	health = clampi(health - damage, 0, max_health)
	if health <= 0:
		defeat.emit()
	
	
	
	if stagger <= 0:
		poise -= clampi(poise - damage, 0, max_poise)
	else:
		poise = clampi(poise - stagger, 0, max_poise)
	if poise <= 0:
		poise_broken.emit()
