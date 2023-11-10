extends StaticBody2D

enum Direction {
	UP,
	LEFT,
	DOWN,
	RIGHT,
}

@export var bounce_speed := 500.0
@export var direction: Direction = Direction.UP

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bounce_player: AudioStreamPlayer = $BouncePlayer

func _ready() -> void:
	rotation = -direction * PI / 2

func on_collision(collider: Object) -> void:
	animation_player.play(&"bounce")
	bounce_player.play()
	if collider is CharacterBody2D:
		var target_velocity: Vector2 = collider.velocity
		match direction:
			Direction.UP:
				target_velocity.x = 0
				target_velocity.y = -bounce_speed
			Direction.DOWN:
				target_velocity.x = 0
				target_velocity.y = bounce_speed
			Direction.LEFT:
				target_velocity.x = -bounce_speed
			Direction.RIGHT:
				target_velocity.x = bounce_speed
		
		if collider.has_method(&"bounce"):
			collider.bounce(target_velocity)

func take_hit(amount: float, attacker: Node2D = null, hit_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0) -> void:
	animation_player.play(&"bounce")
