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
var is_placing = false
var inaccuracy = 0.0
var camera
var rotation_helper

func _ready():
  camera = $rotation/camera
  rotation_helper = $rotation

  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
  process_input()
  process_movement(delta)

func process_input():
  process_walk_direction()
  process_jump()
  process_placement()

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

  if input_movement_vector.x != 0 or input_movement_vector.y != 0:
    play_footsteps()
  else:
    $audio_footsteps.stop()

  input_movement_vector = input_movement_vector.normalized()

  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

func process_jump():
  if Input.is_action_pressed("jump") and is_on_floor():
    vel.y = JUMP_SPEED

func process_placement():
  if !is_placing:
    return

  if Input.is_action_just_pressed("placement"):
    $audio_placement.play()

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

  inaccuracy = vel.length()

func _input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
    self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

    var camera_rot = rotation_helper.rotation_degrees
    camera_rot.x = clamp(camera_rot.x, -80, 80)
    rotation_helper.rotation_degrees = camera_rot

func play_footsteps():
  if $audio_footsteps.playing:
    return

  $audio_footsteps.pitch_scale = rand_range(0.75, 0.95)
  $audio_footsteps.play()

func enable_placing():
  is_placing = true
  $rotation/guns.disable()

func disable_placing():
  is_placing = false
  $rotation/guns.enable()
