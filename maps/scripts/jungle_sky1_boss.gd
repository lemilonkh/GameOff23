extends Room

@export var dragon_mouth_offset := 224
@export var above_floor_height := 896

@onready var dragon: Node2D = $Dragon
@onready var tile_map: TileMap = $TileMap
@onready var credits: MarginContainer = $CanvasLayer/Credits

func spawn_dragon() -> void:
	# lock player in room
	tile_map.set_layer_enabled(2, true)
	dragon.rise()

func enable_dragon() -> void:
	dragon.enable()

func _on_dragon_death() -> void:
	#var game := Game.get_singleton()
	#game.has_killed_sky_boss = true
	#game.fade_out_music()
	fight_finished.emit()
	
	await get_tree().create_timer(6.0).timeout
	credits.start(false) # no auto stop

func _on_credits_finished() -> void:
	Game.get_singleton().fade_out_music()
	await get_tree().create_timer(4.0).timeout
	GameManager.get_singleton().back_to_menu()
