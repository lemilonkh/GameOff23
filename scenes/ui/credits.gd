extends Control

signal finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	show()
	animation_player.play("RESET")
	animation_player.queue("fade_in")
	animation_player.queue("scroll")
	await animation_player.animation_finished
	stop()

func stop():
	animation_player.play_backwards("fade_in")
	await animation_player.animation_finished
	finished.emit()
	hide()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not animation_player.get_playing_speed() < 0:
		stop()
		get_viewport().set_input_as_handled()
