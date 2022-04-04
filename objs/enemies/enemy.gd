extends KinematicBody

const MAX_HEALTH = 100
const DEFAULT_DAMAGE = 10
const DEFAULT_ATTACK_TIMEOUT = 0.333

var health = MAX_HEALTH
var dead_scene : PackedScene
var enemy_damage = DEFAULT_DAMAGE
var attack_target : Spatial = null
var attack_timeout = DEFAULT_ATTACK_TIMEOUT
var attack_time = 0

onready var audio_hit = $audio_hit
onready var dead_enemies = get_parent().get_parent().find_node("dead_enemies")

func _ready():
  set_meta("type", "enemy")

  dead_scene = preload("res://objs/enemies/dead_alien.tscn")

func _physics_process(delta):
  attack(delta)

func take_damage(damage):
  health -= damage

  took_damage()

  if is_dead():
    die()

func is_dead():
  return health <= 0

func die():
  var dead_enemy : Spatial = dead_scene.instance()

  dead_enemy.transform = self.transform
  dead_enemy.transform.origin.y = 0

  dead_enemies.add_child(dead_enemy)

  get_parent().remove_child(self)

func is_attacking():
  return attack_target != null

func start_attacking(obj):
  attack_target = obj

func stop_attacking():
  attack_target = null
  attack_time = 0

func do_attack_animation():
  # NOTE: override in child script
  pass

func took_damage():
  # NOTE: override in child script
  pass

func attack(delta):
  if !is_attacking():
    return

  if attack_target.is_dead():
    stop_attacking()
    return

  if attack_time < attack_timeout:
    attack_time += delta
    return

  do_attack_animation()
  attack_target.take_damage(enemy_damage)
  attack_time = 0
