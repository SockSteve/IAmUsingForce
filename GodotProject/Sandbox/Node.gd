extends Node

@onready var something = preload("res://Scenes/Weapons/MeleeWeapons/Cutter/Cutter.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	something = something.instantiate()
	var package = PackedScene.new()
	package.pack(something)
	ResourceSaver.save(package, "res://Savegame/package.tscn")
	
