extends KinematicBody

const GRAVITY = -32.8
const MAX_SPEED = 5
const JUMP_SPEED = 7
const LADDER_SPEED = 2.69
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const MAX_SPRINT_SPEED = 10
const SPRINT_ACCEL = 9

export var is_disabled = false

var vel = Vector3()
var dir = Vector3()
var is_sprinting = false
var can_climb_ladder = false
var inaccuracy = 0.0
var camera
var rotation_helper

onready var guns = $rotation/camera/guns

func _ready():
  camera = $rotation/camera
  rotation_helper = $rotation

  if is_disabled:
    camera.current = false
    guns.disable()

  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
  if is_disabled:
    return

  process_input()
  process_movement(delta)

func process_input():
  process_sprint()
  process_walk_direction()
  process_jump()

func process_sprint():
  if !is_sprinting and Input.is_action_just_pressed("sprint"):
    guns.play_run_transition()
    is_sprinting = true
    $sprint_timer.start()

func process_walk_direction():
  dir = Vector3()
  var cam_xform = camera.get_global_transform()
  var input_movement_vector = Vector2()

  if can_climb_ladder:
    vel.y = 0

  if Input.is_action_pressed("forward"):
    if can_climb_ladder:
      vel.y = LADDER_SPEED
    else:
      input_movement_vector.y += 1
  if Input.is_action_pressed("back"):
    if can_climb_ladder and !is_on_floor():
      vel.y = -LADDER_SPEED
    else:
      input_movement_vector.y -= 1
  if Input.is_action_pressed("strafe_left"):
    input_movement_vector.x -= 1
  if Input.is_action_pressed("strafe_right"):
    input_movement_vector.x += 1

  if input_movement_vector.x != 0 or input_movement_vector.y != 0:
    if is_sprinting:
      guns.play_run_animation()
    else:
      guns.play_walk_animation()

    play_footsteps()
  else:
    $audio_footsteps.stop()

  if is_sprinting and input_movement_vector.y == 0:
    guns.play_walk_transition()
    is_sprinting = false
    $sprint_timer.stop()

  input_movement_vector = input_movement_vector.normalized()

  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

func process_jump():
  if Input.is_action_pressed("jump") and is_on_floor():
    vel.y = JUMP_SPEED

func process_movement(delta):
  dir.y = 0
  dir = dir.normalized()

  if !is_on_floor() and !can_climb_ladder:
    vel.y += delta * GRAVITY

  var hvel = vel
  hvel.y = 0

  var target = dir

  if is_sprinting:
    target *= MAX_SPRINT_SPEED
  else:
    target *= MAX_SPEED

  var accel
  if dir.dot(hvel) > 0:
    if is_sprinting:
      accel = SPRINT_ACCEL
    else:
      accel = ACCEL
  else:
    accel = DEACCEL

  hvel = hvel.linear_interpolate(target, accel * delta)
  vel.x = hvel.x
  vel.z = hvel.z
  vel = move_and_slide(vel, Vector3(0, 1, 0), true, 4, deg2rad(MAX_SLOPE_ANGLE))

  inaccuracy = vel.length()

func _input(event):
  if is_disabled:
    return

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
  $rotation/camera/guns.disable()

func disable_placing():
  if !is_disabled:
    $rotation/camera/guns.enable()

func _on_sprint_timer_timeout():
  guns.play_walk_transition()
  is_sprinting = false

func enable_climb_ladder():
  can_climb_ladder = true

func disable_climb_ladder():
  can_climb_ladder = false
