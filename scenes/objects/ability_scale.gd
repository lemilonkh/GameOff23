extends Area2D

@export var ability: Player.Ability
@export var ability_sprite_colors: Array[Color]
@export var ability_particle_colors: Array[Color]

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var collect_duration := 0.5

func _ready() -> void:
	sprite.modulate = ability_sprite_colors[ability]
	particles.process_material.color = ability_particle_colors[ability]
	collect_duration = animation_player.get_animation(&"collect").length

func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"gain_ability"):
		body.gain_ability(ability)
		animation_player.play(&"collect")
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite, "global_position", body.global_position, collect_duration)
		tween.tween_property(particles, "interp_to_end", 1.0, collect_duration)
		tween.tween_callback(queue_free)
