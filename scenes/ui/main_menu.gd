extends CanvasLayer

signal game_started(should_load: bool)

const SAVE_FILE := "user://save_data.sav"

@onready var continue_button: Button = $MainMenu/CenterContainer/VBoxContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		continue_button.disabled = false

func _on_continue_button_pressed() -> void:
	game_started.emit(true)

func _on_new_game_button_pressed() -> void:
	# If save data exists, delete it.
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	game_started.emit(false)

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
