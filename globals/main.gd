extends Node

func _physics_process(delta):
  process_input(delta)

func process_input(delta):
  if Input.is_action_pressed("ui_cancel"):
    print(">>> main process_input ui_cancel")
    get_tree().quit()
