extends Control
class_name GameManager

@onready var svc: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var main_menu: CanvasLayer = $SubViewportContainer/SubViewport/MainMenu

const game_scene: PackedScene = preload("res://scenes/game.tscn")
const menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")

var game: Node

func _ready() -> void:
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)
	
	get_viewport().size_changed.connect(on_screen_resized)
	svc.size = Vector2(ProjectSettings.get("display/window/size/viewport_width"), ProjectSettings.get("display/window/size/viewport_height"))
	on_screen_resized()
	
	if OS.has_feature("web"):
		AudioManager.remove_filter()

static func get_singleton() -> GameManager:
	return (GameManager as Script).get_meta(&"singleton") as GameManager

func on_screen_resized() -> void:
	var window_size := DisplayServer.window_get_size()
	var possible_scale := window_size / Vector2i(svc.size)
	var final_scale: Vector2i = max(1, min(possible_scale.x, possible_scale.y)) * Vector2i.ONE
	svc.scale = final_scale
	svc.position = Vector2(window_size) / 2 - svc.size * svc.scale / 2

func back_to_menu() -> void:
	if game:
		game.get_script().set_meta(&"singleton", null)
		game.queue_free()
		game = null
	main_menu = menu_scene.instantiate()
	sub_viewport.add_child(main_menu)
	main_menu.game_started.connect(_on_main_menu_game_started)

func _on_main_menu_game_started(should_load: bool) -> void:
	main_menu.queue_free()
	game = game_scene.instantiate()
	sub_viewport.add_child(game)
	#game.process_mode = Node.PROCESS_MODE_INHERIT
	game.start()
