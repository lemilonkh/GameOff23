extends Path2D

@export var flying_speed := 1.3

@onready var _path := $PathFollow2D
@onready var _enemy := $PathFollow2D/FlyingEnemy
@onready var _state := $StateChart
@onready var _move_states := $StateChart/Root/Movement
@onready var _animation := $PathFollow2D/FlyingEnemy/AnimatedSprite2D
@onready var _position :Vector2 = _enemy.global_position

var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")


func _on_idle_state_processing(delta: float) -> void:
	if false: #(_enemy.global_position - _player.global_position).length() < 100:
		_state.send_event("chase")
	else:
		_state.send_event("fly")


func _on_flying_state_entered() -> void:
	_enemy.position = Vector2.ZERO


func _on_flying_state_physics_processing(delta: float) -> void:
	_path.progress += flying_speed


func _physics_process(delta: float) -> void:
	# Pick flying animation direction
	var state := str(_move_states._active_state).left(4)
	if (state != "Idle") and (state != "Dead"):
		#Get angle
		var direction = (_enemy.global_position - _position).angle()
		var snaped_angle :int = rad_to_deg(round(direction / (PI/2)) * (PI/2))
		snaped_angle = -snaped_angle if snaped_angle == -180 else snaped_angle
		
		if !_animation.is_playing():
			_animation.play("move" + str(snaped_angle))
			_enemy.rotation_degrees = -snaped_angle
		
		_position = _enemy.global_position

