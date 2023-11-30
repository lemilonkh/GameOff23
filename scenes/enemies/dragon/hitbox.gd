extends Area2D

@export var hurt_color := Color("#ce2d3c")
@export var damage_factor := 1.0

@onready var sprite: Sprite2D = get_node_or_null(^"Sprite2D")

func _ready() -> void:
	if !sprite:
		sprite = $Head

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, knockback_force: float = 0) -> void:
	owner.take_hit(amount * damage_factor, attacker, direction, knockback_force)
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(sprite, "modulate", hurt_color, 0.3)
	tween.tween_interval(0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
