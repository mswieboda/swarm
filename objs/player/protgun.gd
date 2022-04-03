extends Spatial

const GUN_DAMAGE = 35
const AMMO_CLIP_SIZE = 30
const BULLET_SPREAD = 30

export (Resource) var fire_sound
export (Resource) var reload_sound
export (Resource) var empty_sound

export var fire_animation = "default"
export var reload_animation = "default"

var ammo = AMMO_CLIP_SIZE
var is_reloading = false

func _ready():
  pass

func _physics_process(_delta):
  process_fire()
  process_reload()

func process_fire():
  if Input.is_action_pressed("fire"):
    if $fire_rate_timer.is_stopped():
      if ammo > 0:
        if Input.get_joy_axis(0, 7) >= 0.5:
            Input.start_joy_vibration(0, 0, 0.2, 0.1)
        fire()
        $fire_rate_timer.start()
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
  var recoil = $recoil_timer.time_left * BULLET_SPREAD # * (1 + player.player_speed / 10)

  $bullet_spread.rotation_degrees.z = rand_range(0, 360)
  $bullet_spread/ray.rotation_degrees.y = rand_range(-recoil, recoil)
  $recoil_timer.start()

func apply_ammo():
  ammo -= 1
  #$HUD/DisplayAmmo/AmmoText.text = str(ammo)

func play_animation(animation):
  $animation.stop()
  $animation.play(animation)

func spawn_impact():
  pass

func spawn_shell():
  pass

func fire_damage():
    var collider : PhysicsBody = $bullet_spread/ray.get_collider()

    if collider:
      if collider.has_meta("type") and collider.get_meta("type") == "enemy":
        collider.take_damage(GUN_DAMAGE)
      else:
        # make bullet hole
        pass

func process_reload():
  if (Input.is_action_pressed("reload")):
    if !is_reloading && ammo != AMMO_CLIP_SIZE:
      is_reloading = true
      play_sound(reload_sound)
      play_animation(reload_animation)
      # TODO: match with the animation
      yield(get_tree().create_timer(1.0), "timeout")
      ammo = AMMO_CLIP_SIZE
      is_reloading = false

func play_sound(sound, volume = 0, delay = 0):
  var audio_node = AudioStreamPlayer.new()
  audio_node.stream = sound
  audio_node.volume_db = volume
  audio_node.pitch_scale = rand_range(0.95, 1.05)
  get_tree().get_root().add_child(audio_node)
  yield(get_tree().create_timer(delay), "timeout")
  audio_node.play()
  yield(get_tree().create_timer(10.0), "timeout")
  audio_node.queue_free()
