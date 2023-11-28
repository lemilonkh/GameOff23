extends Room

@onready var ability_scale: Area2D = $AbilityScale

func spawn_scale() -> void:
	ability_scale.modulate = Color.TRANSPARENT
	ability_scale.visible = true
	var tween := create_tween()
	tween.tween_property(ability_scale, "modulate", Color.WHITE, 1.0)
	tween.tween_callback(func(): ability_scale.monitoring = true)
