extends Node2D

@export var next_room: String = "res://scenes/room_3.tscn"
@export var spawn_position: Vector2 = Vector2(32, 120)

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

	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies_remaining = enemies.size()
	for enemy in enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	var transition = _find_transition_node()
	if transition:
		transition.body_entered.connect(_on_transition_entered)


func _find_transition_node() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child
	return null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_check_npc_interaction()


func _check_npc_interaction() -> void:
	var npcs = get_tree().get_nodes_in_group("NPC")
	for npc in npcs:
		if global_position.distance_to(npc.global_position) < 128.0:
			npc.interact()
			break


func _on_enemy_died() -> void:
	enemies_remaining -= 1


func _on_transition_entered(body: Node) -> void:
	if body.is_in_group("player") and enemies_remaining <= 0:
		if GameManager:
			GameManager.player_health = player.health
		get_tree().change_scene_to_file.call_deferred(next_room)


func _on_player_died() -> void:
	if GameManager:
		GameManager.player_health = player.health
	get_tree().change_scene_to_file.call_deferred("res://scenes/defeat_cutscene.tscn")
