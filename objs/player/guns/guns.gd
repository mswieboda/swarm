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
