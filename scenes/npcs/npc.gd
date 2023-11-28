extends Area2D

@export_category("Dialogue")
@export_file("*.dialogue") var dialogue_file: String
@export var initial_title: String
@export var npc_name: String

var dialogue: DialogueResource
var has_finished_intro := false

func _ready() -> void:
	dialogue = load(dialogue_file)

func _on_body_entered(body: Node2D) -> void:
	Game.get_singleton().start_dialogue(dialogue, initial_title, [{
		npc = self,
		scene = owner,
		game = Game.get_singleton()
	}])

func _on_body_exited(body: Node2D) -> void:
	Game.get_singleton().exit_dialogue()
