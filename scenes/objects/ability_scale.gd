extends Area2D

@export var ability: Player.Ability
@export var ability_sprite_colors: Array[Color]
@export var ability_particle_colors: Array[Color]
@export var move_speed = 16.0 # px/s

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var collect_duration := 0.5
var target_node: Node2D

func _ready() -> void:
	sprite.modulate = ability_sprite_colors[ability]
	particles.process_material = particles.process_material.duplicate()
	particles.process_material.color = ability_particle_colors[ability]
	collect_duration = animation_player.get_animation(&"collect").length
	
	MetSys.register_storable_object(self, queue_free)

func _process(delta: float) -> void:
	if target_node:
		global_position = global_position.move_toward(target_node.global_position, move_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"gain_ability"):
		collision_shape.set_deferred("disabled", true)
		target_node = body
		body.gain_ability(ability)
		MetSys.store_object(self)
		animation_player.play(&"collect")
		create_tween().tween_property(sprite, "position", Vector2.ZERO, 0.5)
		await animation_player.animation_finished
		queue_free()
