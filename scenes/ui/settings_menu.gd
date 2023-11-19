extends PanelContainer

func _on_close_button_pressed() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action(&"ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()

func _on_slider_value_changed(value: float, bus_name: String) -> void:
	var bus_id := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))
