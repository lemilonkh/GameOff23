extends Room

@export_category("Dialogue")
@export var initial_title: String = "start"

@onready var friendly_dragon: Node2D = $FriendlyDragon
@onready var golden_dragon: Node2D = $GoldenDragon
@onready var ability_scale_glide: Area2D = $AbilityScaleGlide
@onready var ability_scale_attack: Area2D = $AbilityScaleAttack

var has_finished_intro := false

const dialogue: DialogueResource = preload("res://dialogue/intro.dialogue")

func _ready() -> void:
	return
	Game.get_singleton().start_dialogue(dialogue, initial_title, [{
		scene = self,
		game = Game.get_singleton(),
		friendly_dragon = friendly_dragon,
		golden_dragon = golden_dragon,
	}])

func spawn_scales() -> void:
	if not is_instance_valid(ability_scale_glide) or not is_instance_valid(ability_scale_attack):
		return
	
	ability_scale_glide.modulate = Color.TRANSPARENT
	ability_scale_glide.visible = true
	var tween := create_tween()
	tween.tween_property(ability_scale_glide, "modulate", Color.WHITE, 1.0)
	tween.tween_callback(func(): ability_scale_glide.monitoring = true)
	
	ability_scale_attack.modulate = Color.TRANSPARENT
	ability_scale_attack.visible = true
	var tween2 := create_tween()
	tween2.tween_property(ability_scale_attack, "modulate", Color.WHITE, 1.0)
	# don't set attack scale to monitoring as it will be stolen by lizard

