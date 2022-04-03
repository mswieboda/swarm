extends "res://objs/base/wall.gd"

func _ready():
  set_meta("type", "supply_depot")

  # TODO: make dead supply depot scene
  dead_scene = preload("res://objs/base/dead_wall.tscn")
