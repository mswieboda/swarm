extends StaticBody

func _on_area_body_entered(body):
  if body.has_method("enable_climb_ladder"):
    body.enable_climb_ladder()

func _on_area_body_exited(body):
  if body.has_method("disable_climb_ladder"):
    body.disable_climb_ladder()
