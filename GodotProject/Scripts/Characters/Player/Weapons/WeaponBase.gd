extends Node
class_name WeaponBase

@export var id := -1
@export var base_name := "PlaceHolder"
@export var upgraded_name := "EvolvedPlaceHolder"

@export var damage := 1
@export var currentAmmunition := 1
@export var maxAmmunition := 1
@export var currentLvl := 1
@export var maxLvl := 9
@export var currentExperience := 0
@export var maxExperiencePerLvl : Dictionary ={}

func setupInputComponent():
	return
	
