extends Area2D

@export var speed := 120.0
@export var damage := 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := Vector2.DOWN:
	set(value):
		direction = value
		rotation = -direction.angle_to(Vector2.DOWN)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"take_hit"):
		var hit_direction := global_position.direction_to(body.global_position)
		body.take_hit(damage, self, hit_direction)
	set_deferred(&"monitoring", false)
	speed = 0
	animation_player.play_backwards(&"grow")
	await animation_player.animation_finished
	queue_free()
