extends Spatial

const DEFAULT_DAMAGE = 15
const DEFAULT_ACCURACY = 0.69

var target = null

func _physics_process(_delta):
  do_firing()

func do_firing():
  if target == null or !$fire_timer.is_stopped():
    return

  fire_at_target()

func fire_at_target():
  if !target.has_method("take_damage"):
    return

  # TODO: rotate to target over a few frames instead of instantly
  look_at(target.global_transform.origin, Vector3.UP)

  # animation
  $AnimationPlayer.play("fire_action")
  $machine_gun/AnimationPlayer.play("fire_anim")

  # fire sound
  $audio_fire.pitch_scale = rand_range(0.95, 1.05)
  $audio_fire.play()

  if randf() < DEFAULT_ACCURACY:
    target.take_damage(DEFAULT_DAMAGE)

func _on_area_body_entered(body):
  if target != null:
    return

  if body.has_meta("type") and body.get_meta("type") == "enemy":
    print(">>> solider found target")
    target = body

func _on_area_body_exited(body):
  if target == null or target != body:
    return

  target = null
