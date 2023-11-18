extends CharacterBody2D

@export var flying_enemy_root : Path2D

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, \
	knockback_force: float = 80) -> void:	
	flying_enemy_root.take_hit(amount, attacker, direction, knockback_force)

