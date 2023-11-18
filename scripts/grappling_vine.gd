extends Area2D
class_name GrapplingVine

@export var move_speed := 800.0 ## px/s
@export var tip_height := 32 ## px
@export var max_range := 12 ## tiles
@export var initial_offset := Vector2(0, -9) ## px from character position
@export var retracted_distance := 8 ## px from player to hide

const TILE_SIZE := 32

@onready var vine_tip: Sprite2D = $VineTip
@onready var vine_tile: Sprite2D = $VineTile
@onready var state_chart: StateChart = $"../StateChart"

var direction_sign := 0

func shoot() -> void:
	if visible:
		return
	
	show()
	direction_sign = -1
	monitoring = true
	monitorable = true
	position = get_parent().global_position + initial_offset
	state_chart.send_event("grapple_shoot")

func retract() -> void:
	direction_sign = 1

func _get_origin() -> Vector2:
	return get_parent().to_global(initial_offset)

func _physics_process(delta: float) -> void:
	if !visible:
		return
	
	var direction := global_position.direction_to(get_parent().global_position)
	if direction_sign == -1:
		direction = Vector2.DOWN
	position += direction_sign * direction * move_speed * delta
	_update_sprites()
	
	var length := _get_origin().distance_to(global_position)
	if direction_sign == 1 and length <= retracted_distance:
		direction_sign = 0
		hide()
		monitoring = false
		monitorable = false
		state_chart.send_event("grapple_retracted")
	elif length >= max_range * TILE_SIZE:
		state_chart.send_event("grapple_miss")
		retract()

func _update_sprites() -> void:
	var length := _get_origin().distance_to(global_position)
	vine_tip.region_rect.size.y = min(length, tip_height)
	vine_tile.region_rect.size.y = max(length - tip_height, 0)
	rotation = _get_origin().angle_to_point(global_position) + PI/2

func _on_body_entered(body: Node2D) -> void:
	state_chart.send_event("grapple_hit")
	direction_sign = 0
