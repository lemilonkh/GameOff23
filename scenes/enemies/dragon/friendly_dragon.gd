extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_animation(anim_name: StringName, wait_for_end: bool = false) -> void:
	animation_player.play(anim_name)
	if wait_for_end:
		await animation_player.animation_finished
