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
## How far up a pogo jump goes in tiles (when attacking an enemy below in mid-air)
@export_range(0, 1000) var pogo_height := 9.0

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
## How long you have to collide with a wall to stop the glide in seconds
@export_range(0, 10) var dash_stop_wall_duration := 0.1

@export_category("Combat")
## How much the player is knocked back when taking damage
@export_range(0, 1000) var default_knockback := 400.0
## How much the player is knocked back when taking damage
@export_range(0, 1000) var spike_knockback := 400.0
## Limit of velocity when applying knockback
@export_range(0, 1000) var max_knockback_velocity := 600.0

@export_category("Status")
## Duration of invulnerability after being hit in settings (also needs to be set in StateChart)
@export var invulnerability_duration := 3.0

@export_category("Abilities")
## Amount of energy gained for each pixel travelled horizontally while gliding. 100 is a full bar
@export var energy_per_pixel := 0.05
## Amount of energy required for healing one heart
@export_range(0, 100) var energy_required_heal := 20.0
## Duration required for healing one heart
@export_range(0, 100) var heal_duration := 3.0
## How fast the grappling vine pulls you upwards (px/s)
@export_range(0, 2000) var grapple_pull_velocity := 600.0
## Distance to the grapple point at which the grapple stops
@export_range(0, 128) var grapple_stop_distance := 64
## Amount of energy required for grappling
@export_range(0, 100) var energy_required_grapple := 10.0
## Amount of energy required for dashing
@export_range(0, 100) var energy_required_dash := 20.0
## How fast the dash moves the player (px/s)
@export_range(0, 2000) var dash_velocity := 1000.0
## Glide movement speed (maximum)
@export_range(0, 2000) var dash_max_speed := 1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

const TILE_SIZE := 32
const HEART_EMPTY := preload("res://sprites/ui/heart_empty.png")
const HEART_HALF := preload("res://sprites/ui/heart_half.png")
const HEART_FULL := preload("res://sprites/ui/heart_full.png")

enum Ability {
	ATTACK,
	HEAL,
	GRAPPLE,
	DASH,
	GLIDE,
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var state_chart: StateChart = $StateChart
@onready var health_container: HBoxContainer = %HealthContainer
@onready var heart: TextureRect = %HealthContainer/TextureRect
@onready var state_chart_debugger: MarginContainer = $CanvasLayer/StateChartDebugger
@onready var combat_animation: AnimationPlayer = $CombatAnimation
@onready var status_animation: AnimationPlayer = $StatusAnimation
@onready var raycast: RayCast2D = $RayCast2D
@onready var floor_distance_shape_cast: ShapeCast2D = $FloorDistanceShapeCast
@onready var energy_progress: TextureProgressBar = %EnergyProgress
@onready var heal_particles: GPUParticles2D = $HealParticles
@onready var wind_particles: GPUParticles2D = $WindParticles
@onready var grappling_vine: GrapplingVine = $GrapplingVine

# SFX
@onready var jump_player: AudioStreamPlayer = $JumpPlayer
@onready var run_player: AudioStreamPlayer = $RunPlayer
@onready var run_timer: Timer = $RunTimer
@onready var take_damage_player: AudioStreamPlayer = $TakeDamagePlayer
@onready var glide_player: AudioStreamPlayer = $GlidePlayer
@onready var heal_player: AudioStreamPlayer = $HealPlayer
@onready var melee_player: AudioStreamPlayer = $MeleePlayer
@onready var ability_not_available_player: AudioStreamPlayer = $AbilityNotAvailablePlayer
@onready var grapple_player: AudioStreamPlayer = $GrapplePlayer
@onready var dash_player: AudioStreamPlayer = $DashPlayer
@onready var pogo_player: AudioStreamPlayer = $PogoPlayer

var health := max_health
var is_invulnerable := false
var energy := 0.0:
	set(value):
		energy = max(min(value, 100), 0)
		energy_progress.value = energy

var max_speed := default_max_speed
var gravity_factor := 1.0
var acceleration := default_acceleration
var deceleration := default_deceleration
var vertical_acceleration := 0.0
var last_direction := 1.0
var reset_position: Vector2
var long_jump_time := jump_increase_time
var is_gliding := false
var is_move_disabled := false
var on_wall_timer := 0.0
var heal_timer := 0.0
var energy_drain := 0.0
var can_air_jump := false

var abilities: Array[Ability] = []

func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, knockback_force: float = default_knockback) -> void:
	if is_invulnerable:
		return

	health -= amount
	take_damage_player.play()
	
	if health <= 0:
		health = 0
		state_chart.send_event("death")
	else:
		state_chart.send_event("take_hit")
		velocity += knockback_force * direction
		velocity = velocity.limit_length(max_knockback_velocity)
	
	_update_health()

func on_enter():
	# Position for kill system. Assigned when entering new room (see game.gd).
	reset_position = position
	# Make sure player doesn't remain frozen after skipped dialogue etc.
	is_move_disabled = false

func teleport(target_position: Vector2) -> void:
	grappling_vine.global_position = target_position
	camera.position_smoothing_enabled = false
	global_position = target_position
	await get_tree().create_timer(0.1).timeout
	camera.position_smoothing_enabled = true

func bounce(target_direction: Vector2, bounce_distance: float) -> void:
	if target_direction.y != 0:
		# make bounce height consistent
		var distance := bounce_distance * TILE_SIZE - _get_floor_distance()
		velocity.y = target_direction.y * Utils.calculate_jump_velocity(distance, gravity)
	else:
		velocity.y = 0
	
	if target_direction.x != 0:
		var distance := bounce_distance * TILE_SIZE
		velocity.x = target_direction.x * Utils.calculate_jump_velocity(distance, default_deceleration)
	else:
		velocity.x = 0
	
	if velocity.y < 0:
		state_chart.send_event("bounce")

func apply_wind() -> void:
	vertical_acceleration = wind_acceleration

func stop_wind() -> void:
	vertical_acceleration = 0.0

func gain_ability(ability: Ability) -> void:
	if not ability in abilities:
		abilities.push_back(ability)

func increase_health(amount: int) -> void:
	max_health += amount
	health += amount
	_update_max_health()
	_update_health()

func _ready() -> void:
	_update_max_health()
	state_chart_debugger.enabled = false
	on_enter()

func _update_max_health() -> void:
	for child in health_container.get_children():
		health_container.remove_child(child)
	for i in range(0, max_health, 2):
		var new_heart := heart.duplicate()
		health_container.add_child(new_heart)

func _update_health() -> void:
	for i in range(0, max_health, 2):
		var current_heart: TextureRect = health_container.get_child(i/2)
		if health > i + 1:
			current_heart.texture = HEART_FULL
		elif health > i:
			current_heart.texture = HEART_HALF
		else:
			current_heart.texture = HEART_EMPTY

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction and not is_move_disabled:
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
		# fall through one way platforms
		if Input.is_action_just_pressed(&"move_down"):
			position += 2 * Vector2.DOWN
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
		state_chart.send_event("hit_wall_dash")
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
	if event.is_action_pressed(&"attack"):
		if Ability.ATTACK in abilities:
			state_chart.send_event("attack")
	elif event.is_action_pressed(&"jump"):
		if is_on_floor() or raycast.is_colliding() or can_air_jump:
			long_jump_time = 0
			state_chart.send_event("jump")
		elif Ability.GLIDE in abilities:
			state_chart.send_event("glide")
	elif event.is_action_released(&"jump"):
		long_jump_time = jump_increase_time
		state_chart.send_event("jump_released")
	elif event.is_action_pressed(&"heal"):
		if Ability.HEAL in abilities:
			state_chart.send_event("heal")
	elif event.is_action_released(&"heal"):
		if Ability.HEAL in abilities:
			state_chart.send_event("heal_released")
	elif event.is_action_pressed("grapple"):
		_start_grapple()
	elif event.is_action_pressed(&"dash"):
		_start_dash()
	elif event.is_action_pressed("debug"):
		state_chart_debugger.enabled = not state_chart_debugger.enabled

func _start_grapple() -> void:
	if not Ability.GRAPPLE in abilities:
		return
	if grappling_vine.visible:
		ability_not_available_player.play()
		return
	if energy < energy_required_grapple:
		ability_not_available_player.play()
		return
	
	grapple_player.play()
	grappling_vine.shoot(velocity)

func _start_dash() -> void:
	if not Ability.DASH in abilities:
		return
	if energy < energy_required_dash:
		ability_not_available_player.play()
		return
	
	state_chart.send_event("dash")

func _get_floor_distance() -> float:
	if floor_distance_shape_cast.is_colliding():
		var collision_point := floor_distance_shape_cast.get_collision_point(0)
		return collision_point.y - floor_distance_shape_cast.global_position.y
	else:
		return 0.0

func _on_animation_finished() -> void:
	state_chart.send_event("finished")

func _on_combat_animation_finished(_anim_name: StringName) -> void:
	state_chart.send_event("combat_finished")

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
	glide_player.play()
	$Glider.show()

func _on_glide_state_physics_processing(delta: float) -> void:
	energy += energy_per_pixel * abs(velocity.x) * delta

func _on_gliding_state_exited() -> void:
	is_gliding = false
	gravity_factor = 1.0
	acceleration = default_acceleration
	deceleration = default_deceleration
	max_speed = default_max_speed
	glide_player.stop()
	$Glider.hide()

func _on_death_state_entered() -> void:
	max_speed = 0
	# TODO show game over popup with prompt to reload from last checkpoint

func _on_death_state_exited() -> void:
	#position = reset_position
	max_speed = default_max_speed
	health = max_health
	_update_health()
	Game.get_singleton().respawn_player()

func _on_hurtbox_hit(body: Node2D) -> void:
	# only pogo if enemy is directly below
	if not is_on_floor(): # and floor_distance_shape_cast.is_colliding():
		var distance := pogo_height * TILE_SIZE - _get_floor_distance()
		velocity.y = -Utils.calculate_jump_velocity(distance, gravity)
		pogo_player.play()
		state_chart.send_event("hit")

func _on_hurtbox_tile_hit(tilemap: TileMap) -> void:
	if not is_on_floor():
		var distance := pogo_height * TILE_SIZE - _get_floor_distance()
		velocity.y = -Utils.calculate_jump_velocity(distance, gravity)
		state_chart.send_event("hit")

func _on_attack_started() -> void:
	is_move_disabled = true
	if not is_on_floor() and Input.is_action_pressed("move_down"):
		$Hurtbox/Left.disabled = true
		$Hurtbox/Right.disabled = true
		$Hurtbox/Down.disabled = false
	else:
		$Hurtbox/Left.disabled = last_direction > 0
		$Hurtbox/Right.disabled = last_direction <= 0
		$Hurtbox/Down.disabled = true
		
	combat_animation.play(&"Attack")
	melee_player.play()

func _on_attack_ended() -> void:
	is_move_disabled = false

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

func _on_heal_state_entered() -> void:
	heal_particles.emitting = true
	heal_timer = 0
	energy_drain = energy_required_heal / heal_duration
	velocity = Vector2.ZERO
	acceleration = 0

func _on_heal_state_processing(delta: float) -> void:
	if energy > 0:
		energy -= energy_drain * delta
	else:
		state_chart.send_event("heal_stop")
		return
	
	if health == max_health:
		state_chart.send_event("heal_stop")
		return
	
	heal_timer += delta
	if heal_timer > heal_duration:
		heal_timer -= heal_duration
		health += 1
		_update_health()
		heal_player.play()

func _on_heal_state_exited() -> void:
	heal_particles.emitting = false
	energy_drain = 0
	heal_timer = 0
	acceleration = default_acceleration

func _on_pulling_state_entered() -> void:
	# consume energy when grapple hits
	energy -= energy_required_grapple

func _on_pulling_state_physics_processing(delta: float) -> void:
	var grapple_distance := global_position.distance_to(grappling_vine.global_position)
	if grapple_distance < grapple_stop_distance:
		grappling_vine.retract()
		return

	var grapple_direction := global_position.direction_to(grappling_vine.global_position)
	velocity = grapple_pull_velocity * grapple_direction

func _on_run_timer_timeout() -> void:
	if is_on_floor() and signf(velocity.x) != 0:
		run_player.play()

func _on_no_jump_state_entered() -> void:
	if Ability.GLIDE in abilities and Input.is_action_pressed(&"jump"):
		state_chart.send_event("glide")

func _on_dash_state_entered() -> void:
	var dash_direction := Vector2(last_direction, -1).normalized()
	velocity = dash_direction * dash_velocity
	is_invulnerable = true
	max_speed = dash_max_speed
	is_move_disabled = true
	energy -= energy_required_dash
	
	var dash_angle := dash_direction.angle_to(Vector2.UP)
	wind_particles.rotation = -dash_angle
	wind_particles.emitting = true
	combat_animation.play(&"Dash")
	dash_player.play()

func _on_dash_state_exited() -> void:
	is_invulnerable = false
	wind_particles.emitting = false
	max_speed = default_max_speed
	is_move_disabled = false
	velocity = Vector2.ZERO

func _on_can_jump_state_entered() -> void:
	can_air_jump = true

func _on_can_jump_state_exited() -> void:
	can_air_jump = false

func _on_take_hit_state_entered() -> void:
	#is_move_disabled = true
	pass

func _on_take_hit_state_exited() -> void:
	#is_move_disabled = false
	pass
