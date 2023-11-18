extends Area2D

@export var speed := 10.0
@export var hit_amount := 1.0
@export var knockback_force := -1.0
@export var life_time := 1.0

@onready var _trail := $Trail
@onready var _explosion := $Explosion

var _start_time : float
var _hit := false
var enemy : Node2D


func _ready():
	_start_time = Time.get_ticks_msec()
	_trail.emitting = true


func _physics_process(delta):
	if _hit:
		return
	var move_direction = Vector2(speed, 0)
	self.position += move_direction.rotated(self.rotation)
	if Time.get_ticks_msec() - _start_time > (life_time*1000):
		self.queue_free()


func _on_body_entered(body):
	# Inform player of hit
	if body.is_in_group("Player"):
		if body.has_method("take_hit"):
			var direction: Vector2 = (body.global_position - self.global_position).normalized()
			if knockback_force >= 0:
				body.take_hit(hit_amount, enemy, direction, knockback_force)
			else:
				body.take_hit(hit_amount, enemy, direction)
	
	# Play hit animation
	_hit = true
	_trail.emitting = false
	await get_tree().create_timer(0.03).timeout
	_trail.visible = false
	_explosion.emitting = true
	await get_tree().create_timer(0.5).timeout
	self.queue_free()

