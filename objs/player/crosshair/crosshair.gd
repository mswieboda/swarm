extends Node2D

const MARGIN = 13
const RATIO = 3

onready var player = get_node("/root/world/player")
var movement_speed = 0.0

func _ready():
  position = get_viewport().size / 2
# warning-ignore:return_value_discarded
  get_tree().connect("screen_resized", self, "_on_screen_resized")

func _process(_delta):
  movement_speed = player.inaccuracy

  $left.position.x = clamp(-MARGIN + (movement_speed * -RATIO), -MARGIN * 2, -MARGIN)
  $top.position.y = clamp(-MARGIN + (movement_speed * -RATIO), -MARGIN * 2, -MARGIN)
  $right.position.x = clamp(MARGIN + (movement_speed * RATIO), MARGIN, MARGIN * 2)
  $bottom.position.y = clamp(MARGIN + (movement_speed * RATIO), MARGIN, MARGIN * 2)

func _on_screen_resized():
  position = get_viewport().size / 2
