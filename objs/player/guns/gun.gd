extends Spatial

const DEFAULT_DAMAGE = 35
const DEFAULT_AMMO_CLIP_SIZE = 30
const DEFAULT_BULLET_SPREAD = 30
const HEIGHT_LAYERING_RATIO = 0.01 # ray hit, extra height for texture layering

export (AudioStream) var fire_sound
export (AudioStream) var reload_sound
export (AudioStream) var empty_sound

export (PackedScene) var bullet_impact
export (PackedScene) var blood_scene

export var fire_animation = "default"
export var reload_animation = "default"
export var run_animation = "default"
export var run_transition = "default"
export var walk_animation = "default"

export var damage = DEFAULT_DAMAGE
export var ammo_clip_size = DEFAULT_AMMO_CLIP_SIZE
export var bullet_spread_amount = DEFAULT_BULLET_SPREAD

onready var guns_root = get_parent().get_parent()
onready var player = guns_root.get_parent().get_parent().get_parent()
onready var bullet_spread = guns_root.get_node("bullet_spread")
onready var ray = bullet_spread.get_node("ray")

var ammo
var is_reloading = false
var is_enabled = false

func _ready():
  is_enabled = false
  visible = false
  ammo = ammo_clip_size

func _physics_process(_delta):
  if !is_enabled:
    return

  process_fire()
  process_reload()

func update_hud_ammo():
  guns_root.update_hud_ammo(ammo)

func enable():
  is_enabled = true
  visible = true
  update_hud_ammo()

func disable():
  is_enabled = false
  visible = false

func process_fire():
  if !Input.is_action_pressed("fire") or !$fire_rate_timer.is_stopped() or player.is_sprinting or is_reloading:
    return

  if ammo > 0:
    if Input.get_joy_axis(0, 7) >= 0.5:
      Input.start_joy_vibration(0, 0, 0.2, 0.1)
    fire()
  else:
    play_sound(empty_sound)

  $fire_rate_timer.start()

func fire():
  play_sound(fire_sound)
  play_animation(fire_animation)
  fire_damage()
  spawn_impact()
  spawn_shell()
  apply_recoil()
  apply_ammo()

func apply_recoil():
  var recoil = $recoil_timer.time_left * bullet_spread_amount # * (1 + player.player_speed / 10)

  bullet_spread.rotation_degrees.z = rand_range(0, 360)
  ray.rotation_degrees.y = rand_range(-recoil, recoil)
  $recoil_timer.start()

func apply_ammo():
  ammo -= 1
  update_hud_ammo()

func play_walk_animation():
  if is_reloading:
    return

  play_animation(walk_animation, false)

func play_run_transition():
  if is_reloading:
    return

  play_animation(run_transition)

func play_run_animation():
  if is_reloading:
    return

  play_animation(run_animation, false)

func play_walk_transition():
  if is_reloading:
    return

  play_animation_backwards(run_transition)

func play_animation(animation, stop = true):
  if stop:
    $AnimationPlayer.stop()
  $AnimationPlayer.play(animation)

func play_animation_backwards(animation, stop = true):
  if stop:
    $AnimationPlayer.stop()
  $AnimationPlayer.play(animation, -1, -1, true)

func spawn_impact():
  if !ray.is_colliding():
    return

  var body = ray.get_collider()

  if body is RigidBody or !body.is_inside_tree():
    return

  var impact

  if body.has_meta("type") and body.get_meta("type") == "enemy":
    impact = blood_scene.instance()
  else:
    impact = bullet_impact.instance()

  body.add_child(impact)

  if !impact.is_inside_tree():
    return

  var position = ray.get_collision_point()
  var normal = ray.get_collision_normal()

  impact.global_transform.origin = position
  impact.global_transform.origin += normal * HEIGHT_LAYERING_RATIO
  impact.global_transform.basis = perpendicular_basis_from_normal(normal)
  impact.rotation_degrees.z = rand_range(0, 360)

func spawn_shell():
  pass

func fire_damage():
  var collider : PhysicsBody = ray.get_collider()

  if collider:
    if collider.has_meta("type") and collider.get_meta("type") == "enemy":
      collider.take_damage(damage)
    else:
      # make bullet hole
      pass

func process_reload():
  if !Input.is_action_pressed("reload") or is_reloading or ammo == ammo_clip_size or player.is_sprinting:
    return

  is_reloading = true

  play_sound(reload_sound, 13)
  play_animation(reload_animation)

  yield(get_tree().create_timer(0.5), "timeout")

  ammo = ammo_clip_size

  update_hud_ammo()

  is_reloading = false

func play_sound(sound, volume = 0, delay = 0, pitch = null):
  var audio_node = AudioStreamPlayer.new()
  audio_node.stream = sound
  audio_node.volume_db = volume

  if pitch == null:
    audio_node.pitch_scale = rand_range(0.95, 1.05)
  else:
    audio_node.pitch_scale = pitch

  get_tree().get_root().add_child(audio_node)

  yield(get_tree().create_timer(delay), "timeout")

  audio_node.play()

  yield(get_tree().create_timer(10.0), "timeout")

  audio_node.queue_free()

func perpendicular_basis_from_normal(normal : Vector3):
  # find the axis with the smallest component
  var min_ind = 0
  var min_axis = abs(normal.x)

  if abs(normal.y) < min_axis:
    min_ind = 1
    min_axis = abs(normal.y)
  if abs(normal.z) < min_axis:
    min_ind = 2

  var right

  # leave the minimum axis in its place,
  # swap the other two to get a vector perpendicular to the normal vector
  if min_ind == 0:
    right = Vector3(normal.x, -normal.z, normal.y)
  elif min_ind == 1:
    right = Vector3(-normal.z, normal.y, normal.x)
  elif min_ind == 2:
    right = Vector3(-normal.y, normal.x, normal.z)

  var up = normal.cross(right)

  return Basis(right, up, normal)
