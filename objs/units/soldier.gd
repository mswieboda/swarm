extends Spatial

const DEFAULT_DAMAGE = 10
const DEFAULT_ACCURACY = 0.61

var target : PhysicsBody = null
var other_targets = []

func _physics_process(_delta):
  get_new_target()
  do_firing()

func get_new_target():
  if target != null and (target.is_inside_tree() and target.has_method("is_dead") and !target.is_dead()):
    return

  if other_targets.size() > 0:
    target = other_targets.pop_front()
  else:
    target = null

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

  # restart fire timer
  $fire_timer.start()

  if randf() < DEFAULT_ACCURACY:
    target.take_damage(DEFAULT_DAMAGE)

func _on_area_body_entered(body):
  if body.has_meta("type") and body.get_meta("type") == "enemy":
    if target == null:
      target = body
    else:
      other_targets.append(body)

func _on_area_body_exited(body):
  if !body.has_meta("type") or body.get_meta("type") != "enemy":
    return

  if target == body:
    target = null
  else:
    var index = other_targets.find(target)

    if index >= 0:
      other_targets.remove(index)
