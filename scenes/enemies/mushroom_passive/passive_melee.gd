extends Area2D

@export var hit_amount := 1.0
@export var hit_speed := 2.0
@export var knockback_force := 2.0
@export var enemy: CharacterBody2D
@export var _attack: AudioStreamPlayer

@onready var _collision := $CollisionShape2D

var _timer = Time.get_ticks_msec()


func _ready():
	var _player = get_tree().get_first_node_in_group("Player")


func _process(delta: float) -> void:
	if (Time.get_ticks_msec() - _timer >= hit_speed*1000):
		for body in get_overlapping_bodies():
			_on_body_entered(body)


func _on_body_entered(body):
	# Inform player of hit
	if body.is_in_group("Player"):
		if body.has_method("take_hit"):
			var direction: Vector2 = (body.global_position - self.global_position).normalized()
			if knockback_force >= 0:
				body.take_hit(hit_amount, enemy, direction, knockback_force)
			else:
				body.take_hit(hit_amount, enemy, direction)
	_attack.play()
	_timer = Time.get_ticks_msec()

