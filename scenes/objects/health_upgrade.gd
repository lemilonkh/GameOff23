extends Area2D

@export var move_speed := 120.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target_node: Node2D

func _ready() -> void:
	MetSys.register_storable_object(self, queue_free)

func _process(delta: float) -> void:
	if not target_node:
		return

	global_position = global_position.move_toward(target_node.global_position, move_speed * delta)
	if global_position.distance_to(target_node.global_position) < 1:
		set_process(false)
		target_node.increase_health(2)
		MetSys.store_object(self)
		var tween := create_tween().set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 0.3)
		tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		target_node = body
