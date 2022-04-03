extends StaticBody

const MAX_HEALTH = 100

var health = MAX_HEALTH
var dead_scene : PackedScene

func _ready():
  set_meta("type", "wall")

  dead_scene = preload("res://objs/base/dead_wall.tscn")

func take_damage(damage):
  health -= damage

  if is_dead():
    die()

func is_dead():
  return health <= 0

func just_died():
  # NOTE: override this in child scripts
  pass

func die():
  var dead_wall : Spatial = dead_scene.instance()

  dead_wall.transform = self.transform
  dead_wall.transform.origin.y = 0

  get_parent().add_child(dead_wall)

  just_died()

  get_parent().remove_child(self)


func _on_area_body_entered(body):
  if body.has_meta("type") and body.get_meta("type") == "enemy":
    body.start_attacking(self)
