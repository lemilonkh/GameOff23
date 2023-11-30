extends CanvasLayer

signal game_started(should_load: bool)

@export var background_scroll_speed := 60.0 ## px/s

const SAVE_FILE := "user://save_data.sav"

@onready var continue_button: Button = $MainMenu/CenterContainer/VBoxContainer/VBoxContainer/ContinueButton
@onready var new_game_button: Button = $MainMenu/CenterContainer/VBoxContainer/VBoxContainer/NewGameButton
@onready var camera_2d: Camera2D = $Camera2D
@onready var settings_menu: MarginContainer = $SettingsMenu
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	if OS.has_feature("web"):
		quit_button.hide()
	_update_buttons()

func _update_buttons() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		continue_button.disabled = false
		continue_button.grab_focus()
	else:
		continue_button.disabled = true
		new_game_button.grab_focus()

func _process(delta: float) -> void:
	camera_2d.position.x += delta * background_scroll_speed

func _on_button_pressed() -> void:
	$ButtonClickPlayer.play()

func _on_button_hover() -> void:
	$ButtonHoverPlayer.play()

func _on_continue_button_pressed() -> void:
	game_started.emit(true)

func _on_new_game_button_pressed() -> void:
	# If save data exists, delete it.
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	game_started.emit(false)

func _on_settings_pressed() -> void:
	settings_menu.show()
	settings_menu.focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_menu_closed() -> void:
	_update_buttons()
