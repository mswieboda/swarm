extends Spatial

const DISTANCE_MIN = 35
const DISTANCE_MAX = 45
const WAVE_ENEMY_MULTIPLIER = 5
const WAVE_TIMER = 5
const GAME_OVER_TIMER = 1

var wave = 0
var wave_timer = 0
var game_over_timer = 0
var is_next_wave = true
var is_game_over = false

onready var supply_depot = get_node("base/supply_depot")
var crawler_scene : PackedScene

func _ready():
  crawler_scene = preload("res://objs/enemies/crawler.tscn")
  randomize()
  init_next_wave()

func _physics_process(delta):
  if Input.is_action_just_pressed("spawn"):
    spawn_enemy(crawler_scene)

  draw_hud()

  if is_next_wave:
    next_wave(delta)
  else:
    check_end_wave()
    check_end_game(delta)

func spawn_enemy(scene):
  var enemy = scene.instance()
  var xform = Transform()

  xform.origin = spawn_vector()

  enemy.global_transform = xform

  $enemies.add_child(enemy)

func spawn_vector():
  var distance = rand_range(DISTANCE_MIN, DISTANCE_MAX)

  var x = rand_range(-distance, distance)
  var z_sign = 1

  if randf() >= 0.5:
    z_sign = -1

  var z = sqrt(pow(distance, 2) + pow(x, 2)) * z_sign
  var v = Vector3(x, 0, z)

  return v

func num_enemies():
  return $enemies.get_child_count()

func draw_hud():
  var enemies = num_enemies()

  $hud/margin/vbox/wave.text = "wave: " + str(wave)
  $hud/margin/vbox/enemies.text = "enemies: " + str(enemies)

  var info = ""

  if is_next_wave:
    info = "next wave starting: " + str(WAVE_TIMER - wave_timer)
  elif is_game_over:
    info = "game over"
  else:
    info = "base health: " + str(supply_depot.health)

  $hud/margin/vbox/info.text = info

func check_end_game(delta):
  if !is_game_over:
    return

  if game_over_timer <= GAME_OVER_TIMER:
    game_over_timer += delta
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    $hud/margin/center/game_over_dialog.show()

func check_end_wave():
  var enemies = num_enemies()

  if enemies <= 0:
    init_next_wave()

func init_next_wave():
  is_next_wave = true
  wave += 1
  wave_timer = 0

func next_wave(delta):
  if wave_timer <= WAVE_TIMER:
    wave_timer += delta
    return

  is_next_wave = false

  for n in range(wave * WAVE_ENEMY_MULTIPLIER):
    spawn_enemy(crawler_scene)

func _on_game_over_dialog_confirmed():
  restart()

func restart():
  get_tree().reload_current_scene()
