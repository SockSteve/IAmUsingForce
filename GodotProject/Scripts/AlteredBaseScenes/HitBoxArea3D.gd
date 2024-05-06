class_name HitBoxArea3D
extends Area3D

@export var damage : float = 1.0
@export var special : Dictionary = {}

signal apply_damage(damage_amount:float, special_effect:Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(damageable_body_entered)
	area_entered.connect(damageable_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func damageable_body_entered(body):
	if body.is_in_group("damageables"):
		emit_signal("apply_damage",damage,special)

func damageable_area_entered(body):
	if body.is_in_group("damageables"):
		emit_signal("apply_damage",damage,special)

