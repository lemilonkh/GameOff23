extends Path2D

@export var health := 3.0
@export var flying_speed := 1.3
@export var attack_speed := 150.0
@export var retreat_speed := 150.0
@export var done_retreat_distance := 5.0
@export var projectile: PackedScene
@export var melee: PackedScene
@export var use_melee := true
@export var use_ranged := true
@export var attack_switch_distance := 55.0 
@export var gravity := 10.0 

# Attack timings
@export var min_fly_time := 2.0
@export var max_fly_time := 7.0
@export var attack_distance := 20.0
@export var max_player_distance := 400.0
@export var max_prev_distance := 10.0
@export var min_player_distance := 2.0
@export var max_chase_time := 2.0
@export var max_start_chase_time := 15.0
@export var max_chase_position_time := 3.0

@onready var _path := $PathFollow2D
@onready var _path_follow := $PathFollow2D
@onready var _enemy := $PathFollow2D/FlyingEnemy
@onready var _state := $StateChart
@onready var _move_states := $StateChart/Root/Movement
@onready var _sprite := $PathFollow2D/FlyingEnemy/AnimatedSprite2D
@onready var _sprite_wings := $PathFollow2D/FlyingEnemy/AnimatedSprite2D/AnimatedSprite2D
@onready var _animations := $PathFollow2D/FlyingEnemy/AnimationPlayer
@onready var _collision := $PathFollow2D/FlyingEnemy/CollisionShape2D
@onready var _attack_spawner := $PathFollow2D/FlyingEnemy/AttackSpawner
@onready var _attack: AudioStreamPlayer = $PathFollow2D/FlyingEnemy/SoundEffects/Attack
@onready var _hit: AudioStreamPlayer = $PathFollow2D/FlyingEnemy/SoundEffects/Hit
@onready var _position : Vector2 = _enemy.global_position

var _player: Node2D
var _hit_effect := false
var _player_visible := false
var _fly_time : float 
var _player_distance : float
var _chase_time : float
var _start_chase_time : float
var _chase_position : Vector2
var _chase_position_time : float


func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, \
	knockback_force: float = 80) -> void:
	health -= amount
	_state.send_event("hit")
	if health <= 0:
		_state.send_event("dead")


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")


func _on_idle_state_processing(delta: float) -> void:
	_state.send_event("fly")


func _on_flying_state_entered() -> void:
	_fly_time = Time.get_ticks_msec()
	_enemy.position = Vector2.ZERO


func _on_flying_state_physics_processing(delta: float) -> void:
	_path.progress += flying_speed
	if Time.get_ticks_msec() - _fly_time >= randf_range(min_fly_time, max_fly_time)*1000.0:
		if _player_visible and _player_distance < 400:
			_state.send_event("chase")


func _on_chase_state_entered() -> void:
	_start_chase_time = Time.get_ticks_msec()
	_chase_time = _start_chase_time
	_chase_position_time = _start_chase_time
	_chase_position = _enemy.global_position


func _on_chase_state_physics_processing(delta: float) -> void:
	# Rotation
	_enemy.look_at(_player.global_position)
	
	# Direction
	var distance :Vector2 = _player.global_position - _enemy.global_position
	_enemy.velocity = distance.normalized() * attack_speed
	_enemy.move_and_slide()
	_enemy.velocity = Vector2.ZERO
	
	# Attack and state switch
	if abs(distance.length()) < attack_distance:
		_state.send_event("attack")
	
	if _player_visible and _player_distance <= max_player_distance:
		_chase_time = Time.get_ticks_msec()
	if abs((_enemy.global_position - _chase_position).length()) > max_prev_distance:
		_chase_position = _enemy.global_position
		_chase_position_time = Time.get_ticks_msec()
	
	var curr_time = Time.get_ticks_msec() 
	if abs(distance.length()) < min_player_distance or \
		curr_time - _chase_time > max_chase_time*1000.0 or \
		curr_time - _start_chase_time > max_start_chase_time*1000.0 or \
		curr_time - _chase_position_time > max_chase_position_time*1000.0:
		_state.send_event("retreat")


func _on_retreat_state_entered() -> void:
	_collision.disabled = true


func _on_retreat_state_physics_processing(delta: float) -> void:
	# Rotation
	_enemy.look_at(to_global(curve.get_closest_point(to_local(_enemy.global_position))))
	
	# Direction
	var distance :Vector2 = to_global(curve.get_closest_point(to_local(_enemy.global_position))) \
		- _enemy.global_position
	_enemy.velocity = distance.normalized() * retreat_speed
	_enemy.move_and_slide()
	_enemy.velocity = Vector2.ZERO
	
	# State switch
	if abs(distance.length()) < done_retreat_distance:
		_path_follow.progress = curve.get_closest_offset(to_local(_enemy.global_position))
		_collision.disabled = false
		_state.send_event("fly")


func _on_dead_state_entered():
	# prevent further collisions with this enemy
	_enemy.collision_layer = 0
	_enemy.global_rotation = 0.0
	_sprite.position.y += 15
	_sprite.play("die")
	_animations.play("death")
	await _animations.animation_finished
	await get_tree().create_timer(1.0).timeout
	self.queue_free()


func _on_attack_state_entered() -> void:
	var attack : Node2D 
	if abs((_player.global_position - _enemy.global_position).length()) < \
		attack_switch_distance and use_melee:
		attack = melee.instantiate()
	elif use_ranged:
		attack = projectile.instantiate()
	else:
		return
	_attack_spawner.add_child(attack)
	attack.look_at(_player.global_position)
	attack.enemy = self
	_attack.play()
	_state.send_event("passive")


func _on_hit_state_entered():
	_hit_effect = true
	_state.send_event("passive")
	_state.send_event("to_retreat")
	_animations.play("knockback")
	_hit.play()


func _physics_process(delta: float) -> void:
	var state := str(_move_states._active_state)
	
	# Calculate movement
	if state.left(4) == "Dead":
		_enemy.velocity.y += gravity
		_enemy.move_and_slide()
	
	# Pick flying animation direction
	if (state.left(4) != "Idle") and (state.left(4) != "Dead"):
		#Get angle
		#var direction = (_enemy.global_position - _position).angle()
		
		_sprite.scale.x = -1 if _enemy.global_position.x - _position.x > 0 else 1
		_position = _enemy.global_position
		
		if !_sprite.is_playing():
			_sprite.play("move")
			_sprite_wings.play("move")
	
	# Update player visibility and distance
	var space_state := get_world_2d().direct_space_state
	var from = _enemy.global_transform.origin
	var to := _player.global_transform.origin
	var query := PhysicsRayQueryParameters2D.create(from, to)
	var result := space_state.intersect_ray(query)
	if result:
		_player_visible = (result["collider"] == _player)
	_player_distance = abs((_enemy.global_position - _player.global_position).length())

