extends "res://objs/enemies/enemy.gd"

const SPEED = 3
const CRAWLER_DAMAGE = 10
const MAX_SLOPE_ANGLE = 75

var target : Spatial = null

func _ready():
  enemy_damage = CRAWLER_DAMAGE
  dead_scene = preload("res://objs/enemies/dead_crawler.tscn")

func _physics_process(delta):
  if has_target():
    if !is_attacking() and !target.is_dead():
      move_towards_target(delta)
  else:
    set_new_target()

func move_towards_target(_delta):
  $animation.play("crawling_action")

  var velocity = -transform.basis.z * SPEED
  var _v = move_and_slide(velocity, Vector3(0, 1, 0), true, 4, deg2rad(MAX_SLOPE_ANGLE))

func set_new_target():
  var supply_depot = get_tree().get_root().find_node("supply_depot", true, false)
  target = supply_depot

  if has_target():
    look_at(target.global_transform.origin, Vector3.UP)

func has_target():
  return target != null

func do_attack_animation():
  $animation.play("hitting_action")

func took_damage():
  $audio_squish.pitch_scale = rand_range(0.75, 1.15)
  $audio_squish.play()
