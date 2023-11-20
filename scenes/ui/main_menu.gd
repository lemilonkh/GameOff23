extends CanvasLayer

signal game_started(should_load: bool)

@export var background_scroll_speed := 5.0 ## px/s

const SAVE_FILE := "user://save_data.sav"

@onready var continue_button: Button = $MainMenu/CenterContainer/VBoxContainer/VBoxContainer/ContinueButton
@onready var settings_menu: PanelContainer = $SettingsContainer/SettingsMenu
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		continue_button.disabled = false

func _process(delta: float) -> void:
	camera_2d.position.x += delta * background_scroll_speed

func _on_continue_button_pressed() -> void:
	game_started.emit(true)

func _on_new_game_button_pressed() -> void:
	# If save data exists, delete it.
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	game_started.emit(false)

func _on_settings_pressed() -> void:
	settings_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()