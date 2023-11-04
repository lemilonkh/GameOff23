extends CharacterBody2D

@export_category("Stats")
@export_range(0, 20) var max_health := 3.0
@export_range(0, 100) var max_energy := 10.0
@export_range(0, 100) var melee_damage := 1.0

@export_category("Movement")
## Default movement speed
@export_range(0, 1000) var speed := 300.0
## How far up a jump goes
@export_range(0, 1000) var jump_velocity := 430.0
## Percent of previous velocity that remains each frame during normal movement
@export_range(0, 1) var default_inertia := 0.1
## Duration of initial drop for glide in seconds
@export_range(0, 2) var glide_drop_duration := 0.2
## How much you drop at the start of the glide
@export_range(0, 1) var glide_initial_gravity_factor := 0.6
## How much you drop during the rest of the glide
@export_range(0, 1) var glide_gravity_factor := 0.05
## Factor of increase of the current speed when starting a glide
@export_range(0, 5) var glide_speed_factor := 1.5
## Percent of previous velocity that remains each frame during glide
@export_range(0, 1) var glide_inertia := 0.94

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_chart: Node = $StateChart

var health := max_health
var energy := 0.0

var gravity_factor := 1.0
var inertia := default_inertia
var gravity_tween: Tween

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(direction * speed, velocity.x, inertia)
	else:
		velocity.x = lerp(0.0, velocity.x, inertia)
		#velocity.x = move_toward(velocity.x, 0, speed)

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
		velocity.y = -jump_velocity
		state_chart.send_event("jump")

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _play_animation(animation: StringName) -> void:
	sprite.play(animation)

func _on_glide_state_entered() -> void:
	if velocity.y < 0:
		velocity.y = 0
	velocity.x *= glide_speed_factor
	inertia = glide_inertia
	gravity_factor = glide_initial_gravity_factor
	gravity_tween = create_tween().set_trans(Tween.TRANS_EXPO)
	gravity_tween.tween_property(self, "gravity_factor", glide_gravity_factor, glide_drop_duration)

func _on_glide_state_exited() -> void:
	gravity_tween.kill()
	gravity_factor = 1.0
	inertia = default_inertia
