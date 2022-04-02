extends KinematicBody

const GRAVITY = -32.8
const MAX_SPEED = 10
const JUMP_SPEED = 12
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18

var vel = Vector3()
var dir = Vector3()
var is_sprinting = false
var camera
var rotation_helper
var gun : Spatial
var gun_animation : AnimationPlayer

func _ready():
  camera = $rotation/camera
  rotation_helper = $rotation
  gun = $rotation/gun
  gun_animation = $rotation/gun/animation
  
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
  process_input(delta)
  process_movement(delta)

func process_input(delta):
  process_walk_direction()
  process_jump()
  process_fire()

func process_walk_direction():
  dir = Vector3()
  var cam_xform = camera.get_global_transform()
  var input_movement_vector = Vector2()

  if Input.is_action_pressed("forward"):
    input_movement_vector.y += 1
  if Input.is_action_pressed("back"):
    input_movement_vector.y -= 1
  if Input.is_action_pressed("strafe_left"):
    input_movement_vector.x -= 1
  if Input.is_action_pressed("strafe_right"):
    input_movement_vector.x += 1

  input_movement_vector = input_movement_vector.normalized()

  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

func process_jump():
  if Input.is_action_pressed("jump") and is_on_floor():
    vel.y = JUMP_SPEED

func process_fire():
  if Input.is_action_pressed("fire") && !gun_animation.is_playing():
    gun_animation.play("default")
    

func process_movement(delta):
  dir.y = 0
  dir = dir.normalized()

  vel.y += delta * GRAVITY

  var hvel = vel
  hvel.y = 0

  var target = dir
  target *= MAX_SPEED

  var accel
  if dir.dot(hvel) > 0:
    accel = ACCEL
  else:
    accel = DEACCEL

  hvel = hvel.linear_interpolate(target, accel * delta)
  vel.x = hvel.x
  vel.z = hvel.z
  vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
    self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

    var camera_rot = rotation_helper.rotation_degrees
    camera_rot.x = clamp(camera_rot.x, -80, 80)
    rotation_helper.rotation_degrees = camera_rot
