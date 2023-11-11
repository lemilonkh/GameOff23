# A save point object. Colliding with it saves the game.
extends Area2D

@onready var start_time := Time.get_ticks_msec()
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Player entered save point
func _on_body_entered(body: Node2D) -> void:
	if Time.get_ticks_msec() - start_time < 1000:
		return # Small hack to prevent saving at the game start.
	start_time = Time.get_ticks_msec()
	animation_player.play(&"save")
	print("Saving game...")
	
	# Get the game-specific save data Dictionary.
	var save_data := Game.get_singleton().get_save_data()
	# Merge it with the Dicionary from MetSys.
	save_data.merge(MetSys.get_save_data())
	# Save the file.
	FileAccess.open("user://save_data.sav", FileAccess.WRITE).store_var(save_data)
	# Starting coords for the delta vector feature.
	Game.get_singleton().reset_map_starting_coords()
	
#func _draw() -> void:
	# Draws the circle.
	#$CollisionShape2D.shape.draw(get_canvas_item(), Color.BLUE)
