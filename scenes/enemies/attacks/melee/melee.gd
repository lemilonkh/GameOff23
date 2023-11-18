extends Area2D

@export var hit_amount := 1.0
@export var knockback_force := -1.0
@export var hit_wait := 0.3

@onready var _animation := $AnimatedSprite2D
@onready var _collision := $CollisionShape2D
@onready var _transform := self.get_global_transform()

var _start_time : float
var enemy : Node2D

func _ready():
	_animation.play("attack")
	await get_tree().create_timer(hit_wait).timeout
	_collision.disabled = false
	
	# Initialize static transform
	var _player = get_tree().get_first_node_in_group("Player")
	look_at(_player.global_position)
	_transform = self.global_transform


func _physics_process(delta: float) -> void:
	self.global_transform = _transform


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

