extends CanvasLayer

var _hearts: Array[AnimatedSprite2D] = []

@onready var fireball_indicator: Sprite2D = $"Fireball Cooldown Indicator"


func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			_hearts.append(child)
	_hearts.sort_custom(func(a, b): return a.position.x < b.position.x)


func set_health(current: int, maximum: int) -> void:
	for i in _hearts.size():
		var heart := _hearts[i]
		heart.visible = i < maximum
		heart.play("full" if i < current else "empty")


func set_fireball_ready(available: bool) -> void:
	fireball_indicator.visible = available
