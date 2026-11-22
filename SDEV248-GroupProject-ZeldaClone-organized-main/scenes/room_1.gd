extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	player.fireball_ready_changed.connect(hud.set_fireball_ready)
	hud.set_health(player.health, player.max_health)


func _on_player_died() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/defeat_cutscene.tscn")
