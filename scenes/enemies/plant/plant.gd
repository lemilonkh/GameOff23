extends Area2D

@export var health := 3.0
@export var attack_wait_time : int = 56
@export var attack_distance := 350.0 
@export var await_animation_time := 0.37
@export var projectile: PackedScene

@onready var _state := $StateChart
@onready var _sprite := $AnimatedSprite2D
@onready var _attack_spawner := $AttackSpawner
@onready var _animations := $AnimationPlayer
@onready var _leafs := $Leafs

var _player: Node2D
var _player_visible := false
var _player_distance : float


func take_hit(amount: float, attacker: Node2D = null, direction: Vector2 = Vector2.ZERO, \
	knockback_force: float = 80) -> void:
	health -= amount
	_state.send_event("hit")
	if health <= 0:
		_state.send_event("dead")


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")


func _on_passive_state_physics_processing(delta: float) -> void:
	if _player_visible and (!(randi() % attack_wait_time)):
		if _player_visible and _player_distance < attack_distance:
			_state.send_event("attack")


func _on_attack_state_entered() -> void:
	_sprite.play("attack")
	await get_tree().create_timer(await_animation_time).timeout
	
	var attack := projectile.instantiate()
	attack.enemy = self
	_attack_spawner.add_child(attack)
	attack.look_at(_player.global_position)
	
	if _sprite.is_playing():
		await _sprite.animation_finished
	_state.send_event("passive")


func _on_hit_state_entered() -> void:
	_animations.play("hit")
	_state.send_event("passive")


func _on_dead_state_entered() -> void:
	_leafs.hide()
	self.position.y += 7 # Spritesheet alignment issue
	_sprite.play("death")
	await _sprite.animation_finished
	self.queue_free()


func _physics_process(delta: float) -> void:
	# Update player visibility and distance
	var space_state := get_world_2d().direct_space_state
	var from = self.global_transform.origin
	var to := _player.global_transform.origin
	var query := PhysicsRayQueryParameters2D.create(from, to)
	var result := space_state.intersect_ray(query)
	if result:
		_player_visible = (result["collider"] == _player)
	_player_distance = abs((self.global_position - _player.global_position).length())

