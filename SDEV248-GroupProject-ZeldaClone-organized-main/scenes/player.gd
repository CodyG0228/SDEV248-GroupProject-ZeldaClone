extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died
signal fireball_ready_changed(available: bool)

@export var speed: float = 70.0
@export var max_health: int = 3
@export var invincibility_time: float = 1.0

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")
@export var fireball_cooldown: float = 0.75

@export var clamp_to_room: bool = true
@export var room_size: Vector2 = Vector2(256, 176)

var health: int
var facing: Vector2 = Vector2.DOWN

var _invincible_timer: float = 0.0
var _last_pressed_axis: String = "y"
var _cooldown_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)
	fireball_ready_changed.emit(true)
	sprite.play("down")
	sprite.stop()


func _physics_process(delta: float) -> void:
	var direction := _get_input_direction()
	velocity = direction * speed
	move_and_slide()

	if clamp_to_room:
		position.x = clamp(position.x, 6.0, room_size.x - 6.0)
		position.y = clamp(position.y, 6.0, room_size.y)

	_update_animation(direction)
	_update_invincibility(delta)
	_update_cooldown(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		_last_pressed_axis = "x"
	elif event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		_last_pressed_axis = "y"

	if event.is_action_pressed("cast"):
		cast_fireball()

	if OS.is_debug_build() and event is InputEventKey and event.pressed \
			and not event.echo and event.physical_keycode == KEY_H:
		take_damage(1)


func _get_input_direction() -> Vector2:
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("move_up", "move_down")

	if x != 0.0 and y != 0.0:
		if _last_pressed_axis == "x":
			y = 0.0
		else:
			x = 0.0

	return Vector2(sign(x), sign(y))


func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
		return

	facing = direction
	var anim := "down"
	if direction.x > 0:
		anim = "right"
	elif direction.x < 0:
		anim = "left"
	elif direction.y < 0:
		anim = "up"

	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


func _update_invincibility(delta: float) -> void:
	if _invincible_timer <= 0.0:
		return
	_invincible_timer -= delta
	sprite.visible = int(_invincible_timer * 20.0) % 2 == 0
	if _invincible_timer <= 0.0:
		sprite.visible = true


func cast_fireball() -> void:
	if _cooldown_timer > 0.0 or health <= 0:
		return
	var fireball := fireball_scene.instantiate()
	fireball.direction = facing
	fireball.position = position + Vector2(0, -14) + facing * 10.0
	get_parent().add_child(fireball)
	_cooldown_timer = fireball_cooldown
	fireball_ready_changed.emit(false)


func _update_cooldown(delta: float) -> void:
	if _cooldown_timer <= 0.0:
		return
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fireball_ready_changed.emit(true)


func take_damage(amount: int) -> void:
	if _invincible_timer > 0.0 or health <= 0:
		return
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()
	else:
		_invincible_timer = invincibility_time


func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
