extends Path2D

@onready var _enemy := $FlyingEnemy
@onready var _state := $StateChart

var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")


func _on_idle_state_processing(delta: float) -> void:
	if (_enemy.global_position - _player.global_position).length() < 100:
		_state.send_event("chase")
	else:
		_state.send_event("fly")


func _on_flying_state_entered() -> void:
	pass # Replace with function body.
