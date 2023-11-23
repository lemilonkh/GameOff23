extends OptionButton

func _ready() -> void:
	var maps := MetSys.map_data.assigned_scenes.keys()
	for map in maps:
		var item: String = map.trim_suffix(".tscn").trim_prefix("/")
		add_item(item)

func _on_item_selected(index: int) -> void:
	var map := "/" + get_item_text(index) + ".tscn"
	var game := Game.get_singleton()
	game.on_room_changed(map)
	if game.map.has_node("SpawnMarker"):
		var spawn_marker: Node2D = game.map.get_node("SpawnMarker")
		game.player.teleport(spawn_marker.global_position)
