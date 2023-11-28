extends Node2D

signal death

@export var target: Node2D
@export var max_health := 30.0
@export var move_speed := 100.0

@export_category("Attacks")
@export var claw_up_height := -250
@export var floor_height := 50
@export var claw_up_duration := 0.8
@export var claw_slam_duration := 0.1
@export var claw_return_duration := 1.0
@export var claw_min_distance := 10
@export var claw_max_distance := 300

@onready var state_chart: StateChart = $StateChart
@onready var health_progress: TextureProgressBar = %HealthProgress

@onready var left_claw: Area2D = $BodyWrapper/LeftClaw
@onready var right_claw: Area2D = $BodyWrapper/RightClaw
@onready var left_smash_claw: Hurtbox = $LeftSmashClaw
@onready var right_smash_claw: Hurtbox = $RightSmashClaw
@onready var mouth_marker: Marker2D = %MouthMarker
@onready var head: Sprite2D = %Head

const FIREBALL = preload("res://scenes/enemies/dragon/fireball.tscn")

var health := max_health
var current_attacks := []
var is_dead := false

var left_attacks: Array[Array] = [
	["SmashLeft", "SmashRight", "SmashBoth"],
	["SmashLeft", "Fireball"],
	["Fireball", "SmashBoth"],
]

var right_attacks: Array[Array] = [
	["SmashRight", "SmashLeft", "SmashBoth"],
	["SmashRight", "Fireball"],
	["Fireball", "SmashBoth"],
]

func _ready() -> void:
	if !target:
		target = Game.get_singleton().player
	MetSys.register_storable_object(self, queue_free)

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, knockback_force: float = 0) -> void:
	# TODO play scream sound
	health = max(health - amount, 0)
	health_progress.value = (health / max_health) * 100
	if health <= 0:
		state_chart.send_event("death")

func shoot_fireball() -> void:
	var fireball := FIREBALL.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = mouth_marker.global_position
	fireball.direction = mouth_marker.global_position.direction_to(target.global_position)

func _x_to_global(x_pos: int) -> int:
	return to_global(Vector2.RIGHT * x_pos).x

func smash_down_claw(claw_side: StringName) -> void:
	var claw := left_claw if claw_side == &"left" else right_claw
	var smash_claw := left_smash_claw if claw_side == &"left" else right_smash_claw
	
	var global_up_height := to_global(Vector2(0, claw_up_height)).y
	var global_floor_height := to_global(Vector2(0, floor_height)).y
	
	var camera: ShakeableCamera = get_viewport().get_camera_2d()
	
	claw.hide()
	claw.monitorable = false
	smash_claw.show()
	smash_claw.position = claw.position
	
	var target_x: int
	if claw_side == &"left":
		target_x = clampi(target.global_position.x, _x_to_global(-claw_max_distance), _x_to_global(-claw_min_distance))
	else:
		target_x = clampi(target.global_position.x, _x_to_global(claw_min_distance), _x_to_global(claw_max_distance))
	var target_up_pos := Vector2(target_x, global_up_height)
	var target_floor_pos := Vector2(target_x, global_floor_height)
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(smash_claw, "global_position", target_up_pos, claw_up_duration)
	tween.tween_callback(func(): smash_claw.is_enabled = true)
	tween.tween_property(smash_claw, "global_position", target_floor_pos, claw_slam_duration).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(smash_claw, "modulate", Color("#f33900"), claw_slam_duration)
	tween.tween_callback(func(): camera.add_trauma(0.5))
	tween.tween_interval(0.5)
	tween.tween_callback(func(): smash_claw.is_enabled = false)
	tween.tween_property(smash_claw, "modulate", Color.WHITE, claw_return_duration)
	tween.parallel().tween_property(smash_claw, "position", claw.position, claw_return_duration)
	await tween.finished
	
	claw.show()
	claw.monitorable = true
	smash_claw.hide()
	state_chart.send_event("finished")

func _physics_process(delta: float) -> void:
	head.look_at(target.global_position)
	head.rotation -= PI/2

func _on_smash_left_state_entered() -> void:
	smash_down_claw(&"left")

func _on_smash_right_state_entered() -> void:
	smash_down_claw(&"right")

func _on_smash_both_state_entered() -> void:
	smash_down_claw(&"left")
	smash_down_claw(&"right")

func _on_death_state_entered() -> void:
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	MetSys.store_object(self) # save dragon state so it doesn't respawn
	create_tween().tween_property(head, "rotation", 0, 0.2)
	death.emit()

func _on_choose_attack_state_entered() -> void:
	if current_attacks.size() == 0:
		var is_left := target.global_position.x < global_position.x
		var attacks := left_attacks if is_left else right_attacks
		current_attacks = attacks.pick_random().duplicate()
	
	var next_attack: String = current_attacks.pop_front()
	state_chart.send_event(next_attack)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	state_chart.send_event("animation_finished")

func _on_idle_state_physics_processing(delta: float) -> void:
	var target_pos := Vector2(target.global_position.x, global_position.y)
	global_position = global_position.move_toward(target_pos, move_speed * delta)
