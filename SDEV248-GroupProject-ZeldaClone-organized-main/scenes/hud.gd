extends CanvasLayer

var _hearts: Array[AnimatedSprite2D] = []


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
