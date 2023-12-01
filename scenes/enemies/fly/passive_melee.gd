extends Area2D

@export var hit_amount := 1.0
@export var knockback_force := 10.0
@export var enemy : Path2D

@onready var _collision := $CollisionShape2D



func _ready():
	var _player = get_tree().get_first_node_in_group("Player")


func _on_body_entered(body):
	# Inform player of hit
	if body.is_in_group("Player"):
		if body.has_method("take_hit"):
			var direction: Vector2 = (body.global_position - self.global_position).normalized()
			if knockback_force >= 0:
				body.take_hit(0.0, enemy, direction)
			else:
				body.take_hit(0.0, enemy, direction)

