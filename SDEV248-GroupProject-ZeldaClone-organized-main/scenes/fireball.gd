extends Area2D

@export var speed: float = 150.0
@export var damage: int = 1
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return

	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
