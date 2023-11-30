extends Area2D

func _ready() -> void:
	MetSys.register_storable_object(self, queue_free)

func _on_body_entered(body: Node2D) -> void:
	MetSys.store_object(self)
	queue_free()
