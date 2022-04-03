extends "res://objs/enemies/enemy.gd"

const SPEED = 3
const CRAWLER_DAMAGE = 10

var target : Spatial = null

func _ready():
  enemy_damage = CRAWLER_DAMAGE

func _physics_process(delta):
  if has_target():
    if !is_attacking():
      if target.is_dead():
        var x = 1
      else:
        move_towards_target(delta)
  else:
    set_new_target()

func move_towards_target(delta):
  $animation.play("crawling_action")
  move_and_slide(-transform.basis.z * SPEED)

func set_new_target():
  var base = get_tree().get_root().find_node("supply_depot", true, false)
  target = base

  look_at(target.global_transform.origin, Vector3.UP)

func has_target():
  return target != null

func do_attack_animation():
  $animation.play("hitting_action")
