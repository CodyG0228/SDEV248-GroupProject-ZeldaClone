extends Node2D

@export var next_room: String = "res://scenes/room_2.tscn"
@export var spawn_position: Vector2 = Vector2(136, 120)

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

var enemies_remaining: int = 0

func _unhandled_input(event: InputEvent) -> void:
	print("INPUT EVENT:", event)
	if event.is_action_pressed("interact"):
		print("INTERACT PRESSED")
		_check_npc_interaction()
		
func _ready() -> void:
	# restores health across rooms
	if GameManager:
		player.health = GameManager.player_health
		player.max_health = GameManager.player_max_health

	player.position = spawn_position

	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	player.fireball_ready_changed.connect(hud.set_fireball_ready)
	hud.set_health(player.health, player.max_health)

	# tracked enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies_remaining = enemies.size()
	for enemy in enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	# room transition
	var transition = _find_transition_node()
	if transition:
		transition.body_entered.connect(_on_transition_entered)


func _find_transition_node() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child
	return null


func _check_npc_interaction() -> void:
	# was having a hard time getting the NPC to respond to interactions.
	# i'm leaving this for debugging.
	var npcs = get_tree().get_nodes_in_group("NPC")
	print("NPCs found in group:", npcs.size())
	for npc in npcs:
		var dist = global_position.distance_to(npc.global_position)
		print("NPC:", npc.name, "distance:", dist)
		if dist < 128.0:
			print("Interacting with:", npc.name)
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
