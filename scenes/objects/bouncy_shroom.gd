extends StaticBody2D

enum Direction {
	UP,
	LEFT,
	DOWN,
	RIGHT,
}

@export var bounce_distance := 8.0 ## in tiles
@export var direction: Direction = Direction.UP

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bounce_player: AudioStreamPlayer = $BouncePlayer

func _ready() -> void:
	rotation = -direction * PI / 2

func on_collision(collider: Object) -> void:
	animation_player.play(&"bounce")
	bounce_player.play()
	if collider is CharacterBody2D:
		var target_direction := Vector2.UP
		match direction:
			Direction.UP:
				target_direction = Vector2.UP
			Direction.DOWN:
				target_direction = Vector2.DOWN
			Direction.LEFT:
				target_direction = Vector2.LEFT
			Direction.RIGHT:
				target_direction = Vector2.RIGHT
		
		if collider.has_method(&"bounce"):
			collider.bounce(target_direction, bounce_distance)

func take_hit(amount: float, attacker: Node2D = null, hit_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0) -> void:
	animation_player.play(&"bounce")
