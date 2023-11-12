extends CharacterBody2D
class_name Player

@export_category("Stats")
@export_range(0, 20) var max_health := 6.0
@export_range(0, 100) var max_energy := 10.0
@export_range(0, 100) var melee_damage := 1.0

@export_category("Movement")
## Default movement speed maximum
@export_range(0, 1000) var default_max_speed := 200.0
## Default vertical speed maximum (falling or jumping)
@export_range(0, 1000) var default_max_vertical_speed := 600.0
## Default movement acceleration (speed change per second)
@export_range(0, 2000) var default_acceleration := 2000.0
## Default movement deceleration (speed change per second when breaking)
@export_range(0, 2000) var default_deceleration := 1200.0
## How far up a jump goes
@export_range(0, 1000) var jump_velocity := 240.0
## Variable jump increase cutoff time
@export_range(0, 500) var jump_increase_time := 10.0
## Variable jump accelleration (The higher, the higher the jump)
@export_range(0, 500) var jump_acceleration := 53.0
## How far up a pogo jump goes (when attacking an enemy below in mid-air)
@export_range(0, 1000) var pogo_velocity := 700.0

@export_category("Glide")
## How much you drop during the rest of the glide
@export_range(0, 1) var glide_gravity_factor := 0.1
## Amount of the speed added when starting a glide
@export_range(0, 5) var glide_initial_speed := 0.0
## Glide movement speed (maximum)
@export_range(0, 1000) var glide_max_speed := 400.0
## Speed change per second during gliding
@export_range(0, 1000) var glide_acceleration := 600.0
## Speed change per second during gliding
@export_range(0, 1000) var glide_deceleration := 400.0
## How much a wind gust accelerates the player upwards
@export_range(0, 1000) var wind_acceleration := 800.0
## How long you have to collide with a wall to stop the glide in seconds
@export_range(0, 10) var glide_stop_wall_duration := 0.8

@export_category("Combat")
## How much the player is knocked back when taking damage
@export_range(0, 1000) var default_knockback := 200.0
## How much the player is knocked back when taking damage
@export_range(0, 1000) var spike_knockback := 500.0

@export_category("Status")
## Duration of invulnerability after being hit in settings (also needs to be set in StateChart)
@export var invulnerability_duration := 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

const TILE_SIZE := 32

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var state_chart: StateChart = $StateChart
@onready var health_container: HBoxContainer = %HealthContainer
@onready var heart: TextureRect = %HealthContainer/TextureRect
@onready var state_chart_debugger: MarginContainer = $CanvasLayer/StateChartDebugger
@onready var combat_animation: AnimationPlayer = $CombatAnimation
@onready var status_animation: AnimationPlayer = $StatusAnimation
@onready var raycast: RayCast2D = $RayCast2D
@onready var jump_player: AudioStreamPlayer = $JumpPlayer

const HEART_EMPTY = preload("res://sprites/ui/heart_empty.png")
const HEART_FULL = preload("res://sprites/ui/heart_full.png")

var health := max_health
var energy := 0.0
var is_invulnerable := false

var max_speed := default_max_speed
var gravity_factor := 1.0
var acceleration := default_acceleration
var deceleration := default_deceleration
var vertical_acceleration := 0.0
var last_direction := 1.0
var reset_position: Vector2
var long_jump_time := jump_increase_time
var is_gliding := false
var on_wall_timer := 0.0

var abilities := []

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, knockback_force: float = default_knockback) -> void:
	if is_invulnerable:
		return

	health -= amount
	velocity += knockback_force * direction
	
	if health <= 0:
		health = 0
		state_chart.send_event("death")
	else:
		state_chart.send_event("take_hit")
	
	_update_health()

func on_enter():
	# Position for kill system. Assigned when entering new room (see game.gd).
	reset_position = position

func teleport(target_position: Vector2) -> void:
	camera.position_smoothing_enabled = false
	global_position = target_position
	await get_tree().create_timer(0.1).timeout
	camera.position_smoothing_enabled = true

func bounce(target_direction: Vector2, bounce_distance: float) -> void:
	velocity.x = target_direction.x * Utils.calculate_jump_velocity(bounce_distance * TILE_SIZE, default_deceleration)
	velocity.y = target_direction.y * Utils.calculate_jump_velocity(bounce_distance * TILE_SIZE, gravity)
	if velocity.y < 0:
		state_chart.send_event("bounce")

func apply_wind() -> void:
	vertical_acceleration = wind_acceleration

func stop_wind() -> void:
	vertical_acceleration = 0.0

func _ready() -> void:
	health_container.remove_child(heart)
	for i in range(max_health):
		var new_heart := heart.duplicate()
		health_container.add_child(new_heart)
	state_chart_debugger.enabled = false
	on_enter()

func _update_health() -> void:
	for i in range(max_health):
		var current_heart: TextureRect = health_container.get_child(i)
		if health > i:
			current_heart.texture = HEART_FULL
		else:
			current_heart.texture = HEART_EMPTY

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x += direction * acceleration * delta
		if abs(velocity.x) > max_speed:
			# TODO gradually decrease for bounce/ knockback?
			velocity.x = signf(velocity.x) * max_speed
	else:
		var change := -signf(velocity.x) * deceleration * delta
		if absf(change) > absf(velocity.x):
			velocity.x = 0
		else:
			velocity.x += change

	if signf(velocity.x) != 0:
		last_direction = signf(velocity.x)
		sprite.flip_h = velocity.x < 0
	
	# limit vertical speed
	velocity.y = min(velocity.y, default_max_vertical_speed)
	
	move_and_slide()

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
	
	if is_gliding:
		velocity.y -= vertical_acceleration * delta
	
	if is_on_wall():
		on_wall_timer += delta
		if on_wall_timer > glide_stop_wall_duration:
			state_chart.send_event("hit_wall")
	else:
		on_wall_timer = 0.0
	
	if velocity.length_squared() <= 0.005:
		state_chart.send_event("idle")
	else:
		state_chart.send_event("moving")
	
	# process tile interactions like bounce
	for c in get_slide_collision_count():
		var col := get_slide_collision(c).get_collider()
		if col.has_method("on_collision"):
			col.on_collision(self)
	
	# Long jump velocity counter
	if Input.is_action_pressed("jump"):
		if long_jump_time < jump_increase_time:
			long_jump_time += 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		state_chart.send_event("attack")
	elif event.is_action_pressed("jump"):
		if is_on_floor() or raycast.is_colliding():
			long_jump_time = 0
			state_chart.send_event("jump")
		else:
			state_chart.send_event("glide")
	elif event.is_action_released("jump"):
		long_jump_time = jump_increase_time
		state_chart.send_event("jump_released")
	elif event.is_action_pressed("debug"):
		state_chart_debugger.enabled = not state_chart_debugger.enabled

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _play_animation(animation: StringName) -> void:
	if sprite.is_playing() and sprite.animation in [&"Attack", &"AirAttack"]:
		await sprite.animation_finished
	sprite.play(animation)

func _on_jump_state_entered() -> void:
	velocity.y = -jump_velocity
	jump_player.play()

func _on_jump_state_physics_processing(delta: float) -> void:
	if long_jump_time < jump_increase_time:
		velocity.y -= jump_acceleration/sqrt(long_jump_time)

func _on_gliding_state_entered() -> void:
	velocity.y = 0
	velocity.x += last_direction * glide_initial_speed # TODO initial acceleration instead?
	is_gliding = true
	gravity_factor = glide_gravity_factor
	acceleration = glide_acceleration
	deceleration = glide_deceleration
	max_speed = glide_max_speed

func _on_gliding_state_exited() -> void:
	is_gliding = false
	gravity_factor = 1.0
	acceleration = default_acceleration
	deceleration = default_deceleration
	max_speed = default_max_speed

func _on_death_state_entered() -> void:
	max_speed = 0
	# TODO show game over popup with prompt to reload from last checkpoint

func _on_death_state_exited() -> void:
	position = reset_position
	max_speed = default_max_speed
	health = max_health
	_update_health()

func _on_hurtbox_hit(body: Node2D) -> void:
	if not is_on_floor():
		velocity.y = -pogo_velocity
	state_chart.send_event("hit")

func _on_attack_started() -> void:
	combat_animation.play(&"Attack")

func _on_hitbox_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var shape_transform := PhysicsServer2D.body_get_shape_transform(body_rid, body_shape_index)
	# TODO this always points to the left for tilemap
	var hit_direction := shape_transform.origin.direction_to(global_position)
	take_hit(1, null, hit_direction, spike_knockback)

func _on_invulnerable_state_entered() -> void:
	AudioManager.animate_filter(&"Music", invulnerability_duration)
	status_animation.play("Invulnerable")
	is_invulnerable = true

func _on_invulnerable_state_exited() -> void:
	is_invulnerable = false
	if status_animation.current_animation == "Invulnerable":
		status_animation.stop()
