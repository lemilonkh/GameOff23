extends Control

const SETTINGS_PATH := "user://settings.sav"

@onready var music_slider: HSlider = %MusicSlider
@onready var sounds_slider: HSlider = %SoundsSlider

var settings := {
	"music_volume": 0.8,
	"sounds_volume": 0.8,
}

func _ready() -> void:
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")))
	sounds_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Sounds")))
	
	if FileAccess.file_exists(SETTINGS_PATH):
		# If save data exists, load it.
		var settings_data = FileAccess.open(SETTINGS_PATH, FileAccess.READ).get_var()
		settings.merge(settings_data, true)
		music_slider.value = settings.music_volume
		sounds_slider.value = settings.sounds_volume

func _on_close() -> void:
	hide()
	FileAccess.open(SETTINGS_PATH, FileAccess.WRITE).store_var(settings)

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action(&"ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()

func _on_slider_value_changed(value: float, bus_name: String) -> void:
	var bus_id := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))
	settings[bus_name.to_lower() + "_volume"] = value
