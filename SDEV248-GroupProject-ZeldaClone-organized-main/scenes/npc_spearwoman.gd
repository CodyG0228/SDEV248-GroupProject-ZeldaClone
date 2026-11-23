extends CharacterBody2D

@export var speed: float = 25.0
@export var dialogue_text: String = "Greetings, O Great Wizard..."

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var overlay: CanvasLayer

var _move_dir: Vector2 = Vector2.RIGHT
var _move_timer: float = 0.0


func _ready() -> void:
	var overlays = get_tree().get_nodes_in_group("cutscene_overlay")
	if overlays.size() > 0:
		overlay = overlays[0]
		overlay.hide()


func _physics_process(delta: float) -> void:
	# non-random movement
	_move_timer += delta
	if _move_timer > 3.0:
		_move_timer = 0.0
		_move_dir = -_move_dir

	velocity = _move_dir * speed
	move_and_slide()

	if sprite.animation != "Frontview":
		sprite.play("Frontview")


func interact() -> void:
	if overlay:
		overlay.show_dialogue(dialogue_text)
