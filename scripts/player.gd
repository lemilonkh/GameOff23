extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GLIDE_FACTOR = 0.05
const GLIDE_INERTIA = 0.94

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_chart: Node = $StateChart
@onready var compound_state: Node = $StateChart/CompoundState

var gravity_factor := 1.0
var inertia := 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		state_chart.send_event("grounded")
		velocity.y = 0
	else:
		velocity.y += gravity_factor * gravity * delta
		state_chart.send_event("airborne")
		if velocity.y >= 0:
			state_chart.send_event("falling")

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(direction * SPEED, velocity.x, inertia)
	else:
		velocity.x = lerp(0.0, velocity.x, inertia)
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	if signf(velocity.x) != 0:
		sprite.flip_h = velocity.x < 0

	move_and_slide()

	if velocity.length_squared() <= 0.005:
		state_chart.send_event("idle")
	else:
		state_chart.send_event("moving")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		state_chart.send_event("attack")

func _on_jump_enabled_state_physics_processing(delta):
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state_chart.send_event("jump")

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _on_child_state_entered() -> void:
	var state: String = compound_state._active_state.name
	sprite.play(state)

func _on_fall_state_physics_processing(delta) -> void:
	if Input.is_action_pressed("jump"):
		gravity_factor = GLIDE_FACTOR
		inertia = GLIDE_INERTIA
	else:
		gravity_factor = 1.0
		inertia = 0.0

func _on_fall_state_exited() -> void:
	gravity_factor = 1.0
	inertia = 0.0
