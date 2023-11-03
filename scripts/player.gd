extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GLIDE_INITIAL_GRAVITY_FACTOR = 0.8
const GLIDE_GRAVITY_FACTOR = 0.05
const GLIDE_SPEED_FACTOR = 2.0
const GLIDE_INERTIA = 0.94
const GLIDE_DROP_DURATION = 0.3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_chart: Node = $StateChart

var gravity_factor := 1.0
var inertia := 0.1

func _physics_process(delta: float) -> void:
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

	# Add the gravity.
	if is_on_floor():
		state_chart.send_event("grounded")
		velocity.y = 0
	else:
		velocity.y += gravity_factor * gravity * delta
		state_chart.send_event("airborne")
		if velocity.y >= 0:
			state_chart.send_event("falling")

	if velocity.length_squared() <= 0.005:
		state_chart.send_event("idle")
	else:
		state_chart.send_event("moving")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		state_chart.send_event("attack")
	elif event.is_action_pressed("glide"):
		state_chart.send_event("glide")

func _on_jump_enabled_state_physics_processing(delta):
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state_chart.send_event("jump")

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _play_animation(animation: StringName) -> void:
	sprite.play(animation)

func _on_glide_state_entered() -> void:
	if velocity.y < 0:
		velocity.y = 0
	velocity.x *= GLIDE_SPEED_FACTOR
	inertia = GLIDE_INERTIA
	gravity_factor = GLIDE_INITIAL_GRAVITY_FACTOR
	var tween := create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "gravity_factor", GLIDE_GRAVITY_FACTOR, GLIDE_DROP_DURATION)

func _on_glide_state_exited() -> void:
	gravity_factor = 1.0
	inertia = 0.0
