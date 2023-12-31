# This is the main script of the game. It manages the current map and some other stuff.
extends Node2D
class_name Game

# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String

@onready var player: Player = $Player
@onready var map_container: Node2D = $MapContainer
@onready var load_overlay: ColorRect = %LoadOverlay
@onready var load_progress: ProgressBar = %LoadProgress
@onready var dialogue_balloon: CanvasLayer = $UI/DialogueBalloon

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var drums_player: AudioStreamPlayer = $DrumsPlayer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer

# The current map scene instance.
var map: Node2D
# List of all map paths currently loaded.
var loaded_map_paths: Array[String]
# Map cache
var loaded_maps: Dictionary#[String, PackedScene]

# Number of collected collectibles. Setting it also updates the counter.
var collectibles: int:
	set(count):
		collectibles = count
		%CollectibleContainer.visible = count > 0
		%CollectibleCount.text = "%d/3" % count

# The coordinates of generated rooms. MetSys does not keep this list, so it needs to be done manually.
var generated_rooms: Array[Vector3i]
# The typical array of game events. It's supplementary to the storable objects.
var events: Array[String]
# Is currently loading maps/ showing load screen?
var is_loading := false

# Game related state
var has_killed_jungle_boss := false

func _ready() -> void:
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)
	
	# Freeze player until the game is done loading
	player.process_mode = Node.PROCESS_MODE_DISABLED
	load_maps()

func start() -> void:
	if FileAccess.file_exists("user://save_data.sav"):
		# If save data exists, load it.
		var save_data: Dictionary = FileAccess.open("user://save_data.sav", FileAccess.READ).get_var()
		# Send the data to MetSys (it has extra keys, but it doesn't matter).
		MetSys.set_save_data(save_data)
		# Load various data stored in the dictionary.
		collectibles = save_data.collectible_count
		generated_rooms.assign(save_data.generated_rooms)
		events.assign(save_data.events)
		starting_map = save_data.current_room
		has_killed_jungle_boss = save_data.has_killed_jungle_boss
		player.abilities.assign(save_data.abilities)
		if save_data.has(&"max_health"):
			player.max_health = save_data.max_health
			player.health = save_data.max_health
			player._update_max_health()
			player._update_health()
	else:
		# If no data exists, reset MetSys.
		MetSys.set_save_data()

func respawn_player() -> void:
	# Go to the starting point.
	goto_map(MetSys.get_full_room_path(starting_map))
	# Find the save point and teleport the player to it, to start at the save point.
	var start_point := map.get_node_or_null(^"SavePoint")
	if not start_point:
		await get_tree().process_frame
		start_point = map.get_node_or_null(^"TileMap/SavePoint")
	if not start_point:
		start_point = map.get_node_or_null(^"SpawnMarker")
	if start_point:
		player.teleport(start_point.global_position)

func _on_finish_loading() -> void:
	load_overlay.hide()
	
	respawn_player()
	
	# Connect the room_changed signal to handle room transitions.
	MetSys.room_changed.connect(on_room_changed, CONNECT_DEFERRED)
	# Reset position tracking (feature specific to this project).
	reset_map_starting_coords.call_deferred()
	# Unfreeze player
	player.process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta: float) -> void:
	if is_loading:
		var progress := get_load_progress()
		load_progress.value = progress * 100
		if progress >= 1.0:
			is_loading = false
			_on_finish_loading()

func load_maps() -> void:
	var maps := MetSys.map_data.assigned_scenes.keys()
	for map_path in maps:
		var full_path := get_full_map_path(map_path)
		ResourceLoader.load_threaded_request(full_path, "PackedScene")
		loaded_map_paths.push_back(full_path)
	is_loading = true

func get_full_map_path(map_path: String) -> String:
	if map_path.begins_with("/"):
		map_path = MetSys.settings.map_root_folder + map_path
	return map_path

func get_load_progress() -> float:
	var progress := 0.0
	for map_path in loaded_map_paths:
		var map_progress := []
		var status := ResourceLoader.load_threaded_get_status(map_path, map_progress)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				progress += map_progress[0]
			ResourceLoader.THREAD_LOAD_LOADED:
				progress += 1.0
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load map ", map_path)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Invalid resource at ", map_path)
	
	if loaded_map_paths.size() == 0:
		return 0.0
	return progress / loaded_map_paths.size()

# Loads a room scene and removes the current one if exists.
func goto_map(map_path: String):
	var prev_map_position := Vector2i.MAX
	if map:
		# If some map is already loaded (which is true anytime other than the beginning), remember its position and free it.
		prev_map_position = MetSys.get_current_room_instance().get_base_coords()
		map.queue_free()
		map = null
	
	var full_path := get_full_map_path(map_path)
	print("Entering map ", full_path)
	
	var map_scene: PackedScene
	if not loaded_maps.has(full_path):
		var status := ResourceLoader.load_threaded_get_status(full_path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			push_warning("Map wasn't loaded yet when entering it: ", full_path, ". Blocking to load.")
		elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_warning("Map wasn't queued for loading: ", full_path, ". Blocking to load.")
			ResourceLoader.load_threaded_request(full_path, "PackedScene")
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_warning("Map load failed!: ", full_path)
		
		map_scene = ResourceLoader.load_threaded_get(full_path)
		loaded_maps[full_path] = map_scene
	else:
		map_scene = loaded_maps[full_path]
	
	map = map_scene.instantiate()
	map_container.add_child(map)
	
	# update playing music, drums and ambience based on room
	var music_file := Room.DEFAULT_MUSIC
	var drums_file := Room.DEFAULT_DRUMS
	var ambience_file := Room.DEFAULT_AMBIENCE
	if map is Room:
		music_file = map.music_file
		drums_file = map.drums_file
		ambience_file = map.ambience_file
	
	# TODO async and fade
	if music_file:
		if music_file != music_player.stream.resource_path:
			music_player.stream = load(music_file)
		if !music_player.playing:
			music_player.play()
	else:
		music_player.stop()
	
	if drums_file:
		if drums_file != drums_player.stream.resource_path:
			drums_player.stream = load(drums_file)
		drums_player.play(music_player.get_playback_position())
	else:
		drums_player.stop()
	
	if ambience_file:
		if ambience_file != ambience_player.stream.resource_path:
			ambience_player.stream = load(ambience_file)
		if !ambience_player.playing:
			ambience_player.play()
	else:
		ambience_player.stop()
	
	# Adjust the camera.
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	# Set the current layer to the room's layer.
	MetSys.current_layer = MetSys.get_current_room_instance().get_layer()
	
	# If previous map has existed, teleport the player based on map position difference.
	if prev_map_position != Vector2i.MAX:
		var map_grid_difference := Vector2(MetSys.get_current_room_instance().get_base_coords() - prev_map_position)
		var target_position := player.position - map_grid_difference * MetSys.settings.in_game_cell_size
		player.teleport(target_position)
		player.on_enter()

func fade_out_music() -> void:
	var music_tween := create_tween()
	music_tween.parallel().tween_property(music_player, "volume_db", -80, 4.0)
	music_tween.parallel().tween_property(drums_player, "volume_db", -80, 4.0)
	music_tween.tween_callback(func():
		music_player.stop()
		drums_player.stop()
		music_player.volume_db = 0
		drums_player.volume_db = 0
	)

func _physics_process(delta: float) -> void:
	if not is_loading:
		# Notify MetSys about the player's current position.
		MetSys.set_player_position(player.position)

func on_room_changed(target_map: String):
	# Randomly generated rooms use absolute paths, so this needs to be checked.
	if target_map.is_absolute_path():
		goto_map(target_map)
	else:
		# If target_map is only the scene name (default behavior of assigned scenes), get the full path.
		goto_map(MetSys.get_full_room_path(target_map))

# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

# Project-specific save data Dictionary. It's merged with the MetSys one.
func get_save_data() -> Dictionary:
	return {
		"collectible_count": collectibles,
		"generated_rooms": generated_rooms,
		"events": events,
		"current_room": MetSys.get_current_room_name(),
		"abilities": player.abilities,
		"max_health": player.max_health,
		"has_killed_jungle_boss": has_killed_jungle_boss,
	}

func reset_map_starting_coords():
	$UI/MapWindow.reset_starting_coords()

func start_dialogue(dialogue: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	dialogue_balloon.show()
	dialogue_balloon.start(dialogue, title, extra_game_states)
	player.is_move_disabled = true
	await DialogueManager.dialogue_ended
	player.is_move_disabled = false

func exit_dialogue() -> void:
	dialogue_balloon.hide()
