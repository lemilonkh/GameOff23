extends Node2D
class_name Room

const DEFAULT_MUSIC := "res://music/jungle_music.ogg"
const DEFAULT_DRUMS := "res://music/jungle_drums.ogg"
const DEFAULT_AMBIENCE := "res://sounds/Ambience/Ambience_Jungle.ogg"

@export_file("*.ogg", "*.wav", "*.mp3") var music_file: String = DEFAULT_MUSIC
@export_file("*.ogg", "*.wav", "*.mp3") var drums_file: String = DEFAULT_DRUMS
@export_file("*.ogg", "*.wav", "*.mp3") var ambience_file: String = DEFAULT_AMBIENCE
