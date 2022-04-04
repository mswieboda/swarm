extends Spatial

const MAX_TIME = 5

var time = 0

func _ready():
  pass # Replace with function body.

func _process(delta):
  if time == 0:
    $blood_particles.emitting = true

func _physics_process(delta):
  if time >= MAX_TIME:
    remove_from_scene()
  else:
    time += delta

func remove_from_scene():
  get_parent().remove_child(self)
