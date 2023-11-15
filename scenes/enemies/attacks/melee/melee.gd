extends Area2D

@export var hit_amount := 1.0
@export var knockback_force := -1.0
@export var life_time := 1.0

@onready var _animation := $AnimatedSprite2D

var _start_time : float
var enemy :Node2D


func _ready():
	_animation.play("attack")


func _on_body_entered(body):
	# Inform player of hit
	if body.is_in_group("Player"):
		if body.has_method("take_hit"):
			var direction: Vector2 = (body.global_position - self.global_position).normalized()
			if knockback_force >= 0:
				body.take_hit(hit_amount, enemy, direction, knockback_force)
			else:
				body.take_hit(hit_amount, enemy, direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()

