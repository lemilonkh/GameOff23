extends ColorRect

@onready var settings_container: MarginContainer = $SettingsContainer
@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton

var previous_focus: Control

func pause() -> void:
	get_tree().paused = true
	show()
	previous_focus = get_viewport().gui_get_focus_owner()
	resume_button.grab_focus()

func unpause() -> void:
	get_tree().paused = false
	hide()
	if previous_focus:
		previous_focus.grab_focus()
	elif get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()

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
