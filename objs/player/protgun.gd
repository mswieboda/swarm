extends Spatial

const GUN_DAMAGE = 35

var animation : AnimationPlayer
var audio : AudioStreamPlayer3D
var ray : RayCast

func _ready():
  animation = $animation
  ray = $ray
  audio = $audio

func _physics_process(delta):
  process_fire(delta)

func process_fire(_delta):
  if Input.is_action_just_pressed("fire"):
    # TODO: add inaccuracy after firing, and slowly regain accurracy back over time
    animation.stop()
    animation.play("default")
    audio.play(0.0)

    # ray cast
    ray.force_raycast_update()

    var collider : PhysicsBody = ray.get_collider()

    if collider:
      if collider.has_meta("type") and collider.get_meta("type") == "enemy":
        collider.take_damage(GUN_DAMAGE)
      else:
        # make bullet hole
        pass
