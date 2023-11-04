extends StaticBody2D

@export var bounce_speed := 600.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func on_collision(collider: Object) -> void:
	animation_player.play(&"bounce")
	if collider is CharacterBody2D:
		collider.velocity.y = -bounce_speed
