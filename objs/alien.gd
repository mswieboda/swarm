extends RigidBody

const MAX_HEALTH = 100

var health = MAX_HEALTH
var dead_alien_scene : PackedScene

func _ready():  
  set_meta("type", "enemy")
  
  dead_alien_scene = preload("res://objs/dead_alien.tscn")

func take_damage(damage):
  health -= damage
  
  if health <= 0:
    die()

func die():
  print(">>> alien died")
  
  # spawn dead body, make this obj for removal
  var dead_alien : Spatial = dead_alien_scene.instance()
  
  dead_alien.transform = self.transform
  dead_alien.transform.origin.y = 0
  
  get_parent().add_child(dead_alien)
  
  get_parent().remove_child(self)
