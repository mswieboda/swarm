extends Spatial

onready var machine_gun = $guns/machine_gun

var gun : Spatial

func _ready():
  gun = machine_gun
  gun.enable()

func _physics_process(_delta):
  # TODO: add change weapon logic
  pass

func update_hud_ammo(ammo):
  $hud/ammo.text = str(ammo)

func enable():
  show()
  $crosshair.show()
  $hud/ammo.show()
  gun.enable()

func disable():
  hide()
  $crosshair.hide()
  $hud/ammo.hide()
  gun.disable()

func play_walk_animation():
  gun.get_node("AnimationPlayer").play(gun.walk_animation)

func play_run_transition():
  gun.get_node("AnimationPlayer").play(gun.run_transition)

func play_run_animation():
  gun.get_node("AnimationPlayer").play(gun.run_animation)

func play_walk_transition():
  gun.get_node("AnimationPlayer").play_backwards(gun.run_transition)
