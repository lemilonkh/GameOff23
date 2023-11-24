extends Area2D

@export var move_speed := 120.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target_node: Node2D

func _ready() -> void:
	MetSys.register_storable_object(self, queue_free)

func _process(delta: float) -> void:
	if not target_node:
		return
	global_position = global_position.move_toward(target_node.global_position + Vector2.UP * 32, move_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		target_node = body
	elif body is LockedDoor:
		collision_shape.set_deferred(&"disabled", true)
		target_node = null
		var tween := create_tween().set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "global_position", body.global_position + Vector2.UP * 16, 0.8)
		tween.tween_callback(func():
			body.unlock()
			MetSys.store_object(self)
		)
		tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 0.3)
		tween.tween_callback(queue_free)
