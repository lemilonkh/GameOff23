extends Control

@onready var svc: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var main_menu: CanvasLayer = $SubViewportContainer/SubViewport/MainMenu

const game_scene: PackedScene = preload("res://scenes/game.tscn")

func _ready() -> void:
	get_viewport().size_changed.connect(on_screen_resized)
	svc.size = Vector2(ProjectSettings.get("display/window/size/viewport_width"), ProjectSettings.get("display/window/size/viewport_height"))
	on_screen_resized()

func on_screen_resized() -> void:
	var window_size := DisplayServer.window_get_size()
	var possible_scale := window_size / Vector2i(svc.size)
	var final_scale: Vector2i = max(1, min(possible_scale.x, possible_scale.y)) * Vector2i.ONE
	svc.scale = final_scale
	svc.position = Vector2(window_size) / 2 - svc.size * svc.scale / 2

func _on_main_menu_game_started(should_load: bool) -> void:
	main_menu.queue_free()
	var game := game_scene.instantiate()
	sub_viewport.add_child(game)
	#game.process_mode = Node.PROCESS_MODE_INHERIT
	game.start()
