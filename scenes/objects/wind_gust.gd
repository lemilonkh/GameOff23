extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"apply_wind"):
		body.apply_wind()

func _on_body_exited(body: Node2D) -> void:
	if body.has_method(&"stop_wind"):
		body.stop_wind()
