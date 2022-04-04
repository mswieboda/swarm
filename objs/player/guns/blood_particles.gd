extends Spatial

func _ready():
  $particles.emitting = true

func _on_timer_timeout():
  get_parent().remove_child(self)
  queue_free()
