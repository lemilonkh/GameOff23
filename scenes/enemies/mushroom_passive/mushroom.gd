extends CharacterBody2D

@export var health := 3.0
@export var speed := 40.0
@export var gravity := 200.0
@export var idle_distance_to_player := 10.0
@export var projectile: PackedScene
@export var melee: PackedScene
@export var use_melee := true
@export var use_ranged := true
@export var attack_switch_distance := 55.0 
@export var wait_before_deactivate := 10.0
@export var knockback_amount := 80.0
@export var knockback_decrease := 3.0
@export var attack_wait_time : int = 80
@export var stealth_chance : int = 72
@export var stop_stealth_chance : int = 80

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state: StateChart = $StateChart
@onready var _move_states: CompoundState = $StateChart/Root/Movement
@onready var _animations: AnimationPlayer = $AnimationPlayer
@onready var _left_side: RayCast2D = $Raycasts/RayCastLeft
@onready var _right_side: RayCast2D = $Raycasts/RayCastRight
@onready var _wall_side_1: RayCast2D = $Raycasts/RayCastWall1
@onready var _wall_side_2: RayCast2D = $Raycasts/RayCastWall2
@onready var _attack_spawner: Node2D = $AttackSpawner
@onready var _collider: CollisionShape2D = $CollisionShape2D
@onready var _walk: AudioStreamPlayer = $SoundEffects/Walk
@onready var _hit: AudioStreamPlayer = $SoundEffects/Hit
@onready var _melee: Area2D = $Melee

var _player: Node2D
var _active_time := Time.get_ticks_msec()
var _player_in_range := false
var _hit_effect := false
var _hit_slowdown := 0.0
var _player_visible := false


func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, \
	knockback_force: float = 80) -> void:
	health -= amount
	_state.send_event("hit")
	if health <= 0:
		_state.send_event("dead")


func _ready():
	_player = get_tree().get_first_node_in_group("Player")
	_on_inactive_state_entered()


func _on_area_2d_body_entered(body):
	if body == _player:
		_player_in_range = true
		_state.send_event("activate")


func _on_area_2d_body_exited(body):
	if body == _player:
		_player_in_range = false


func _on_inactive_state_entered():
	_sprite.play("Inactive")


func _on_activate_state_entered():
	_sprite.play("Activate")
	await _sprite.animation_finished
	_state.send_event("idle")


func _on_deactivate_state_entered():
	_sprite.play("Deactivate")
	await _sprite.animation_finished
	_state.send_event("inactive")


func _on_idle_state_processing(delta):
	if not _player_in_range and not _player_visible and (!(randi() % stealth_chance)):
		if not ((_wall_side_1.is_colliding() and _player.position.x - self.position.x > 0) \
			and (_wall_side_2.is_colliding() and _player.position.x - self.position.x < 0)):
			if (_left_side.is_colliding() and _player.position.x - self.position.x > 0) \
				or (_right_side.is_colliding() and _player.position.x - self.position.x < 0):
				_state.send_event("search")
				return
	if abs(_player.position.x - self.position.x) > idle_distance_to_player:
		if not ((_wall_side_1.is_colliding() and _player.position.x - self.position.x < 0) \
			and (_wall_side_2.is_colliding() and _player.position.x - self.position.x > 0)):
			if (_left_side.is_colliding() and _player.position.x - self.position.x < 0) \
				or (_right_side.is_colliding() and _player.position.x - self.position.x > 0):
				_state.send_event("walk")
				return
	_sprite.play("Idle")


func _on_walk_state_entered():
	_sprite.play("Walk")
	await _sprite.animation_finished
	_state.send_event("idle")


func _on_walk_state_physics_processing(delta):
	if  (_player.position.x - self.position.x < 0 and !_left_side.is_colliding()) \
		or (_player.position.x - self.position.x > 0 and !_right_side.is_colliding()):
		_sprite.stop()
		_state.send_event("idle")
		return
	self.velocity.x = speed if _player.position.x - self.position.x > 0 else -speed
	if not _walk.playing:
		_walk.play()


func _on_search_state_physics_processing(delta: float) -> void:
	if  not _left_side.is_colliding() or not _right_side.is_colliding() \
		or _player_in_range or _player_visible: 
		_sprite.stop()
		_state.send_event("idle")
		return
	if (!(randi() % stop_stealth_chance)):
		_sprite.stop()
		_state.send_event("idle_wait")
		return
	if (_wall_side_1.is_colliding() and _sprite.scale.x > 0) \
			or (_wall_side_2.is_colliding() and _sprite.scale.x < 0):
			_state.send_event("idle")
	self.velocity.x = -speed if _player.position.x - self.position.x > 0 else speed
	if not _walk.playing:
		_walk.play()


func _on_walk_state_exited():
	self.velocity.x = 0


func _on_dead_state_entered():
	# prevent further collisions with this enemy
	collision_layer = 0
	_melee.queue_free()
	_sprite.play("Die")
	await _sprite.animation_finished
	_animations.play("death")
	await _animations.animation_finished
	self.queue_free()


func _on_hit_state_entered():
	_hit.play()
	_hit_effect = true
	_animations.play("knockback")
	_state.send_event("passive")


func _on_passive_state_processing(delta):
	if _player_visible and (!(randi() % attack_wait_time)):
		_state.send_event("attack")


func _on_attack_state_entered():
	var attack : Node2D 
	if abs((_player.global_position - self.global_position).length()) < \
		attack_switch_distance and use_melee:
		attack = melee.instantiate()
	elif use_ranged:
		attack = projectile.instantiate()
	else:
		return
	_attack_spawner.add_child(attack)
	attack.look_at(_player.global_transform.origin)
	attack.enemy = self
	_state.send_event("passive")


func _physics_process(delta):
	# Knockback effect
	if _hit_effect:
		_hit_slowdown = knockback_amount
		_hit_effect = false
	_hit_slowdown = max(0, _hit_slowdown - knockback_decrease)
	
	# Calculate final velocty
	var direction := 1 if (_player.position.x - self.position.x < 0) else -1
	velocity.x += _hit_slowdown*direction
	velocity.y = gravity
	move_and_slide()
	velocity = Vector2.ZERO
	
	# When to deactivate
	if (_player_visible and abs((_player.global_position - self.global_position).length()) \
		<= 300) or (not _player_visible and _player_in_range):
		_active_time = Time.get_ticks_msec()
	if Time.get_ticks_msec() - _active_time > wait_before_deactivate*1000:
		_state.send_event("deactivate")
	
	# Change look direction
	var state := str(_move_states._active_state).left(8)
	if (state != "Inactive") and (state != "Deactiva") \
		and (state != "Activate") and (state.left(4) != "Dead"):
		if state.left(6) == "Search":
			_sprite.scale.x = 1 if (_player.position.x - self.position.x < 0) else -1
		else:
			_sprite.scale.x = -1 if (_player.position.x - self.position.x < 0) else 1
	
	# Update player visibility
	var space_state := get_world_2d().direct_space_state
	var from := global_transform.origin
	var to := _player.global_transform.origin
	var query := PhysicsRayQueryParameters2D.create(from, to)
	var result := space_state.intersect_ray(query)
	if result:
		_player_visible = (result["collider"] == _player)
	
	# Handle search
	if state.left(6) == "Search":
		_sprite.play("Walk")
	
	# In check (can be removed)
	if state.left(6) == "Search" or state.left(4) == "Walk":
		if (_wall_side_1.is_colliding() and _sprite.scale.x > 0) \
			or (_wall_side_2.is_colliding() and _sprite.scale.x < 0):
			_state.send_event("idle")

