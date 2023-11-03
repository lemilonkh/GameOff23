extends Area2D

@export var speed = 10
@export var life_time = 1000

@onready var _trail = $Trail
@onready var _explosion = $Explosion

var _start_time
var _hit = false


func _ready():
	_start_time = Time.get_ticks_msec()
	_trail.emitting = true


func _physics_process(delta):
	if _hit:
		return
	var move_direction = Vector2(speed, 0)
	self.position += move_direction.rotated(self.rotation)
	if Time.get_ticks_msec() - _start_time > life_time:
		self.queue_free()


func _on_body_entered(body):
	# TODO: Callback player hit function
	_hit = true
	_trail.emitting = false
	await get_tree().create_timer(0.03).timeout
	_trail.visible = false
	_explosion.emitting = true
	await get_tree().create_timer(0.5).timeout
	self.queue_free()

