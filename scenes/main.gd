extends Spatial

const DISTANCE_MIN = 105
const DISTANCE_MAX = 135
const WAVE_INITIAL_ENEMIES = 30
const WAVE_ENEMY_MULTIPLIER = 20
const WAVE_SPAWNS_PER_INTERVAL = 2
const WAVE_SPAWN_INTERVAL = 1 * 60
const GAME_OVER_TIMER = 1

export (PackedScene) var soldier_scene

var wave = 0
var wave_interval_time = 0
var max_wave_unit_placements = 0
var wave_unit_placements = 0
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

func _physics_process(delta):
  if Input.is_action_just_pressed("start"):
    is_wave_started = true
    $player.disable_placing()

  process_placing()
  check_num_enemies()

  draw_hud()

  if is_wave_ended:
    if is_wave_started:
      next_wave()
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
  # TODO: find y of terrain, and add like 1 or 3 to it
  var y = 11 # estimated max height of terrain
  var v = Vector3(x, y, z)

  return v

func check_num_enemies():
  num_enemies = $enemies.get_child_count()

func draw_hud():
  $hud/margin/vbox/wave.text = "wave %s" % wave
  $hud/margin/vbox/enemies.text = "enemies: %d" % num_enemies

  var wave_info = ""
  var info = ""

  if is_wave_ended:
    wave_info = "wave ended, make preparations and press ENTER to start"
  else:
    wave_info = "next enemy in: " + show_time(wave_interval_timer() - wave_interval_time)

  $hud/margin/vbox/wave_info.text = wave_info

  if is_game_over:
    info = "game over"

  $hud/margin/vbox/info.text = info
  $hud/margin/base_health/vbox/bar/value.text = "%d%%" % supply_depot.health
  $hud/margin/base_health/vbox/bar/health.margin_left = (100 - supply_depot.health) * 3

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
  wave_interval_time = 0
  # TODO: change this based on wave like 3 + wave ? for example
  max_wave_unit_placements = 3
  wave_unit_placements = 0

  $player.enable_placing()

func next_wave():
  var enemies = WAVE_INITIAL_ENEMIES + wave * WAVE_ENEMY_MULTIPLIER

  for _n in range(enemies):
    spawn_enemy(crawler_scene)

  is_wave_ended = false
  is_wave_started = false

func _on_game_over_dialog_confirmed():
  restart()

func restart():
  var _scene = get_tree().reload_current_scene()

func process_placing():
  if !is_wave_ended or is_wave_started or !Input.is_action_just_pressed("placement"):
    return

  if wave_unit_placements >= max_wave_unit_placements:
    # TODO: add messaging saying they can't place any more units
    $player/audio_placement_error.play()
    return

  wave_unit_placements += 1
  $player/audio_placement.play()

  var soldier : Spatial = soldier_scene.instance()
  soldier.global_transform = $player.global_transform
  soldier.rotate_y(deg2rad(180))
  $units.add_child(soldier)
