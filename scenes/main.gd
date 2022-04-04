extends Spatial

const DISTANCE_MIN = 35
const DISTANCE_MAX = 45
const WAVE_ENEMY_MULTIPLIER = 2
const WAVE_SPAWNS_PER_INTERVAL = 1
const WAVE_SPAWN_INTERVAL = 1 * 60
const WAVE_TIMER = 5 * 60
const GAME_OVER_TIMER = 1

var wave = 0
var wave_time = 0
var wave_interval_time = 0
var wave_wait_time = 0
var game_over_time = 0
var num_enemies = 0
var is_wave_ended = false
var is_wave_started = false
var is_game_over = false

onready var supply_depot = get_node("base/supply_depot")
var crawler_scene : PackedScene

func _ready():
  crawler_scene = preload("res://objs/enemies/crawler.tscn")
  randomize()
  end_wave()
  # TODO: implement a timer to start the first wave automatically
  # is_wave_started = true

func _physics_process(delta):
  if Input.is_action_just_pressed("start"):
    is_wave_started = true

  check_num_enemies()

  draw_hud()

  if is_wave_ended:
    if is_wave_started:
      next_wave(delta)
  else:
    check_wave_spawns(delta)
    check_end_wave(delta)
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

func check_num_enemies():
  num_enemies = $enemies.get_child_count()

func draw_hud():
  $hud/margin/vbox/wave.text = "wave: " + str(wave)
  $hud/margin/vbox/enemies.text = "enemies: " + str(num_enemies)

  var wave_info = ""
  var info = ""

  if is_wave_ended:
    wave_info = "wave ended, make preparations and press ENTER to start"
  else:
    wave_info = "wave lasts: " + show_time(WAVE_TIMER - wave_time)
    wave_info += " next enemy in: " + show_time(wave_interval_timer() - wave_interval_time)

  $hud/margin/vbox/wave_info.text = wave_info

  if is_game_over:
    info = "game over"
  else:
    info = "base health: " + str(supply_depot.health)

  $hud/margin/vbox/info.text = info

func show_time(time):
  var mins = floor(time / 60)
  var secs = time - mins * 60

  var result = ""

  if mins > 0:
    result += "%d mins " % mins

  return result + "%.1f secs" % secs

func check_end_game(delta):
  if !is_game_over:
    return

  if game_over_time <= GAME_OVER_TIMER:
    game_over_time += delta
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    $hud/margin/center/game_over_dialog.show()

func check_end_wave(delta):
  if num_enemies <= 0:
    end_wave()
  elif wave_time >= WAVE_TIMER:
    end_wave()
  else:
    wave_time += delta

func wave_interval_timer():
  return WAVE_SPAWN_INTERVAL / (WAVE_SPAWNS_PER_INTERVAL * wave)

func check_wave_spawns(delta):
  if wave_interval_time >= wave_interval_timer():
    wave_interval_time = 0
    spawn_enemy(crawler_scene)
  else:
    wave_interval_time += delta

func end_wave():
  is_wave_ended = true
  wave += 1
  wave_time = 0
  wave_interval_time = 0

func next_wave(delta):
  for _n in range(wave * WAVE_ENEMY_MULTIPLIER):
    spawn_enemy(crawler_scene)

  is_wave_ended = false
  is_wave_started = false

func _on_game_over_dialog_confirmed():
  restart()

func restart():
  var _scene = get_tree().reload_current_scene()
