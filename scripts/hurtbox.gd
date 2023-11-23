extends Area2D
class_name Hurtbox

signal hit(body: Node2D)
signal tile_hit(tilemap: TileMap)

@export_range(0, 50) var damage := 1.0
@export var is_enabled := false: set = set_enabled

func set_enabled(value: bool) -> void:
	if is_enabled != value and is_enabled:
		for body in get_overlapping_bodies():
			deal_damage(body)

	is_enabled = value

func _on_body_entered(body: Node2D) -> void:
	if !is_enabled:
		return
	deal_damage(body)

func deal_damage(body: Node2D) -> void:
	if body.has_method("take_hit"):
		var direction := global_position.direction_to(body.global_position)
		body.take_hit(damage, self, direction)
		hit.emit(body)
	elif body is TileMap:
		tile_hit.emit(body)
