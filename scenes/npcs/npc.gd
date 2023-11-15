extends Area2D

@export_category("Dialogue")
@export var dialogue: DialogueResource
@export var initial_title: String
@export var npc_name: String

func _on_body_entered(body: Node2D) -> void:
	Game.get_singleton().start_dialogue(dialogue, initial_title, [self])

func _on_body_exited(body: Node2D) -> void:
	Game.get_singleton().exit_dialogue()
