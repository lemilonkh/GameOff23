extends ColorRect

func pause() -> void:
	get_tree().paused = true
	show()

func unpause() -> void:
	get_tree().paused = false
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()

func _on_resume_button_pressed() -> void:
	unpause()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()
