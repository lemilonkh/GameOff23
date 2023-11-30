extends Room

@export var dragon_mouth_offset := 224
@export var above_floor_height := 896

@onready var ability_scale: Area2D = $GrappleAbilityScale
@onready var dragon: Node2D = $Dragon
@onready var tile_map: TileMap = $TileMap

func spawn_dragon() -> void:
	# lock player in room
	tile_map.set_layer_enabled(2, true)
	dragon.rise()

func enable_dragon() -> void:
	dragon.enable()

func _on_dragon_death() -> void:
	var game := Game.get_singleton()
	game.has_killed_jungle_boss = true
	game.music_player.stop()
	fight_finished.emit()
	
	if !is_instance_valid(ability_scale):
		printerr("Missing grapple ability scale!")
		return
	
	ability_scale.global_position = dragon.global_position + Vector2.UP * dragon_mouth_offset
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(ability_scale, "modulate", Color.WHITE, 2.0)
	var target_pos := Vector2(ability_scale.global_position.x, above_floor_height)
	tween.tween_property(ability_scale, "global_position", target_pos, 4.0)
	tween.tween_callback(func():
		ability_scale.monitoring = true
	)
