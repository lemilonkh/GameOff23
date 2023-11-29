extends ColorRect

@onready var settings_container: MarginContainer = $SettingsContainer

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
	settings_container.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_menu_button_pressed() -> void:
	unpause()
	GameManager.get_singleton().back_to_menu()
