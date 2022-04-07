extends Spatial

const MAX_TIME = 5

var time = 0

func _ready():
  $blood_particles.emitting = true

  $audio_squeal.pitch_scale = rand_range(0.9, 1.10)
  $audio_squeal.playing = true

func _on_timer_timeout():
  get_parent().remove_child(self)
  queue_free()
