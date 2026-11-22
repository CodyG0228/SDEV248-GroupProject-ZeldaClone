extends CharacterBody2D

signal died

@export var speed: float = 35.0
@export var chase_speed: float = 55.0
@export var chase_range: float = 130.0
@export var patrol_distance: float = 90.0
@export var health: int = 2
@export var contact_damage: int = 1

var _start_position: Vector2
var _patrol_dir: Vector2 = Vector2.RIGHT
var _patrol_target: Vector2
var _player: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_start_position = global_position
	_patrol_target = _start_position + _patrol_dir * patrol_distance


	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]


func _physics_process(delta: float) -> void:
	var move_dir := Vector2.ZERO
	var chasing := false

	if _player:
		var to_player = _player.global_position - global_position
		if to_player.length() <= chase_range:
			move_dir = to_player.normalized()
			chasing = true

	if move_dir == Vector2.ZERO:
		# patrolling back and forth between two points, achieveing the "non-random" instructions.
		move_dir = (_patrol_target - global_position).normalized()
		if global_position.distance_to(_patrol_target) < 8.0:
			_patrol_dir = -_patrol_dir
			_patrol_target = _start_position + _patrol_dir * patrol_distance

	if move_dir != Vector2.ZERO:
		velocity = move_dir * (chase_speed if chasing else speed)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_animation(move_dir)


func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		if sprite.animation != "idle":
			sprite.play("idle")
		return

	if sprite.animation != "walk":
		sprite.play("walk")

	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
