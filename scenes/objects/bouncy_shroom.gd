extends StaticBody2D

enum Direction {
	UP,
	LEFT,
	DOWN,
	RIGHT,
}

@export var bounce_speed := 600.0
@export var direction: Direction = Direction.UP

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	rotation = -direction * PI / 2

func on_collision(collider: Object) -> void:
	animation_player.play(&"bounce")
	if collider is CharacterBody2D:
		match direction:
			Direction.UP:
				collider.velocity.y = -bounce_speed
			Direction.DOWN:
				collider.velocity.y = bounce_speed
			Direction.LEFT:
				collider.velocity.x = -bounce_speed
			Direction.RIGHT:
				collider.velocity.x = bounce_speed
