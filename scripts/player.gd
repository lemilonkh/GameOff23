extends CharacterBody2D

@export_category("Stats")
@export_range(0, 20) var max_health := 3.0
@export_range(0, 100) var max_energy := 10.0
@export_range(0, 100) var melee_damage := 1.0

@export_category("Movement")
## Default movement speed
@export_range(0, 1000) var default_speed := 300.0
## Default movement acceleration (speed change per second)
@export_range(0, 2000) var default_acceleration := 800.0
## Default movement deceleration (speed change per second when breaking)
@export_range(0, 2000) var default_deceleration := 1000.0
## How far up a jump goes
@export_range(0, 1000) var jump_velocity := 430.0
## Duration of initial drop for glide in seconds
@export_range(0, 2) var glide_drop_duration := 0.2
## How much you drop at the start of the glide
@export_range(0, 1) var glide_initial_gravity_factor := 0.6
## How much you drop during the rest of the glide
@export_range(0, 1) var glide_gravity_factor := 0.05
## Factor of increase of the current speed when starting a glide
@export_range(0, 5) var glide_speed_factor := 1.5
## Speed change per second during gliding
@export_range(0, 1000) var glide_acceleration := 50.0
## How much the player is knocked back when taking damage
@export_range(0, 1000) var default_knockback := 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_chart: Node = $StateChart
@onready var health_container: HBoxContainer = %HealthContainer
@onready var heart: TextureRect = %HealthContainer/TextureRect
@onready var state_chart_debugger: MarginContainer = $CanvasLayer/StateChartDebugger

const HEART_EMPTY = preload("res://sprites/ui/heart_empty.png")
const HEART_FULL = preload("res://sprites/ui/heart_full.png")

var health := max_health
var energy := 0.0

var speed := default_speed
var gravity_factor := 1.0
var acceleration := default_acceleration
var gravity_tween: Tween

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, knockback_force: float = default_knockback) -> void:
	health -= amount
	velocity += knockback_force * direction
	_update_health()
	
	if health <= 0:
		health = 0
		state_chart.send_event("death")
	else:
		state_chart.send_event("take_hit")

func _ready() -> void:
	health_container.remove_child(heart)
	for i in range(max_health):
		var new_heart := heart.duplicate()
		health_container.add_child(new_heart)

func _update_health() -> void:
	for i in range(max_health):
		var current_heart: TextureRect = health_container.get_child(i)
		if i <= health:
			current_heart.texture = HEART_FULL
		else:
			current_heart.texture = HEART_EMPTY

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x += direction * default_deceleration * delta
		if abs(velocity.x) > default_speed:
			# TODO gradually decrease for bouncy/ knockback?
			velocity.x = signf(velocity.x) * default_speed
	else:
		var change := -signf(velocity.x) * acceleration * delta
		if absf(change) > absf(velocity.x):
			velocity.x = 0
		else:
			velocity.x += change

	if signf(velocity.x) != 0:
		sprite.flip_h = velocity.x < 0

	move_and_slide()
	for c in get_slide_collision_count():
		var col := get_slide_collision(c)
		if col.get_collider().has_method("on_collision"):
			col.get_collider().on_collision(self)
			if velocity.y < 0:
				state_chart.send_event("jump")

	# Add the gravity.
	if is_on_floor():
		state_chart.send_event("grounded")
		# allow buffered jumps but don't build up gravity
		velocity.y = min(velocity.y, 0)
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
	elif event.is_action_pressed("jump"):
		state_chart.send_event("jump")
	elif event.is_action_pressed("debug"):
		state_chart_debugger.enabled = not state_chart_debugger.enabled

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _play_animation(animation: StringName) -> void:
	sprite.play(animation)

func _on_jump_state_entered() -> void:
	if velocity.y >= 0:
		velocity.y = -jump_velocity

func _on_glide_state_entered() -> void:
	if velocity.y < 0:
		velocity.y = 0
	velocity.x *= glide_speed_factor
	acceleration = glide_acceleration
	gravity_factor = glide_initial_gravity_factor
	gravity_tween = create_tween().set_trans(Tween.TRANS_EXPO)
	gravity_tween.tween_property(self, "gravity_factor", glide_gravity_factor, glide_drop_duration)

func _on_glide_state_exited() -> void:
	gravity_tween.kill()
	gravity_factor = 1.0
	acceleration = default_acceleration

func _on_death_state_entered() -> void:
	print("death")
	speed = 0
	# TODO show game over popup with prompt to reload from last checkpoint
