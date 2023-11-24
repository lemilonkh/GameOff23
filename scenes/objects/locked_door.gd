extends StaticBody2D
class_name LockedDoor

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	MetSys.register_storable_object(self, queue_free)

func unlock() -> void:
	MetSys.store_object(self)
	animated_sprite.play(&"open")
	await animated_sprite.animation_finished
	queue_free()
