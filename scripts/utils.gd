extends Node
class_name Utils

## calculate velocity needed to reach a certain jump height
## @param jump_height intended height in pixels
## Source: https://forum.gamemaker.io/index.php?threads/calculating-the-velocity-needed-to-reach-a-specific-jump-height.47172/post-290540
static func calculate_jump_velocity(jump_height: int, gravity: float) -> float:
	var velocity := sqrt(2 * jump_height * gravity)
	return velocity
