extends Node2D

@export var target: Node2D
@export var claw_up_height := -250
@export var floor_height := 50
@export var claw_up_duration := 0.8
@export var claw_slam_duration := 0.1
@export var claw_return_duration := 1.0

@onready var state_chart: StateChart = $StateChart
@onready var left_claw: Area2D = $LeftClaw
@onready var right_claw: Area2D = $RightClaw
@onready var left_smash_claw: Hurtbox = $LeftSmashClaw
@onready var right_smash_claw: Hurtbox = $RightSmashClaw

func _ready() -> void:
	if !target:
		target = Game.get_singleton().player

func smash_down_claw(claw_side: StringName) -> void:
	var claw := left_claw if claw_side == &"left" else right_claw
	var smash_claw := left_smash_claw if claw_side == &"left" else right_smash_claw
	
	var global_up_height := to_global(Vector2(0, claw_up_height)).y
	var global_floor_height := to_global(Vector2(0, floor_height)).y
	
	var camera: ShakeableCamera = get_viewport().get_camera_2d()
	
	claw.hide()
	smash_claw.show()
	smash_claw.position = claw.position
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(smash_claw, "global_position", Vector2(target.global_position.x, global_up_height), claw_up_duration)
	tween.tween_callback(func(): smash_claw.is_enabled = true)
	tween.tween_property(smash_claw, "global_position", Vector2(target.global_position.x, global_floor_height), claw_slam_duration).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(smash_claw, "modulate", Color("#f33900"), claw_slam_duration)
	tween.tween_callback(func(): camera.add_trauma(0.5))
	tween.tween_interval(0.5)
	tween.tween_callback(func(): smash_claw.is_enabled = false)
	tween.tween_property(smash_claw, "modulate", Color.WHITE, claw_return_duration)
	tween.parallel().tween_property(smash_claw, "position", claw.position, claw_return_duration)
	await tween.finished
	
	claw.show()
	smash_claw.hide()
	state_chart.send_event("finished")

func _on_smash_left_state_entered() -> void:
	smash_down_claw(&"left")
