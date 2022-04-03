extends "res://objs/base/wall.gd"

onready var world = get_node("/root/world")

func _ready():
  set_meta("type", "supply_depot")

  # TODO: make dead supply depot scene
  dead_scene = preload("res://objs/base/dead_wall.tscn")

func just_died():
  world.is_game_over = true
