extends StaticBody2D

signal broken

@export var health := 3.0

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Register the wall as storable. Note that break is passed as callback.
	# If the wall was broken before (store_object() was called), break will be called immediately.
	MetSys.register_storable_object(self, break_wall)

func take_hit(amount: float, attacker: Node2D = null, hit_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0) -> void:
	health -= amount
	particles.emitting = true
	if health <= 0:
		# "Store" the wall, i.e. remember its persistent state.
		MetSys.store_object(self)
		# The callback needs to be called manually when storing.
		break_wall()

func break_wall():
	# Emit the signal to notify other nodes.
	broken.emit()
	# Visual stuff.
	sprite.hide()
	# Make sure the door can't be broken again.
	$CollisionShape2D.queue_free()
