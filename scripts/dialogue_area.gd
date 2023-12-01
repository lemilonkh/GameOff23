extends Area2D

@export_category("Dialogue")
@export_file("*.dialogue") var dialogue_file: String
@export var initial_title: String = "start"

var dialogue: DialogueResource
var has_finished_intro := false

func start_dialogue(title: String) -> void:
	Game.get_singleton().start_dialogue(dialogue, title, [{
		npc = self,
		scene = owner,
		game = Game.get_singleton()
	}])

func _ready() -> void:
	dialogue = load(dialogue_file)
	MetSys.register_storable_object(self, func():
		has_finished_intro = true
	)

func store_finished_intro() -> void:
	if !has_finished_intro:
		MetSys.store_object(self)
	has_finished_intro = true

func _on_body_entered(body: Node2D) -> void:
	start_dialogue(initial_title)
	set_deferred("monitoring", false)

func _on_body_exited(body: Node2D) -> void:
	#Game.get_singleton().exit_dialogue()
	pass
