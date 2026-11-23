extends Node2D

@export_file("*.tscn")
var next_scene: String

@export var spawn_position: Vector2 = Vector2.ZERO

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

var enemies_remaining: int = 0


func _ready() -> void:
	if GameManager:
		player.health = GameManager.player_health
		player.max_health = GameManager.player_max_health

	player.position = spawn_position

	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	player.fireball_ready_changed.connect(hud.set_fireball_ready)

	hud.set_health(player.health, player.max_health)

	var enemies = _get_room_enemies()
	enemies_remaining = enemies.size()

	for enemy in enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	var transition = _find_transition_node()

	if transition:
		transition.monitoring = true
		transition.collision_mask = 1
		transition.body_entered.connect(_on_transition_entered)


func _process(_delta: float) -> void:
	enemies_remaining = _get_room_enemies().size()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_check_npc_interaction()


func _check_npc_interaction() -> void:
	var npcs = get_tree().get_nodes_in_group("NPC")

	for npc in npcs:
		# FIXED: measure from player instead of room
		if player.global_position.distance_to(npc.global_position) < 128.0:
			npc.interact()
			break


func _find_transition_node() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child

	return null


# this will prevent the game including enemies from other rooms,
# which will hinder progression across rooms
func _get_room_enemies() -> Array[Node]:
	var enemies: Array[Node] = []

	for node in find_children("*", "CharacterBody2D", true, false):
		if node.is_in_group("enemy") and is_instance_valid(node):
			enemies.append(node)

	return enemies


func _on_enemy_died() -> void:
	enemies_remaining -= 1


func _on_transition_entered(body: Node) -> void:
	if body.is_in_group("player") and enemies_remaining <= 0:
		if GameManager:
			GameManager.player_health = player.health

		get_tree().change_scene_to_file.call_deferred(next_scene)


func _on_player_died() -> void:
	if GameManager:
		GameManager.player_health = player.health

	get_tree().change_scene_to_file.call_deferred(
		"res://scenes/defeat_cutscene.tscn"
	)
