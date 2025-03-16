extends Node

const SILVER_SCENE_PATH = "res://Interactibles/Money/Silver.tscn"
const GOLD_SCENE_PATH = "res://Interactibles/Money/Gold.tscn"

@onready var silver: PackedScene = preload(SILVER_SCENE_PATH)
@onready var gold: PackedScene = preload(SILVER_SCENE_PATH)
