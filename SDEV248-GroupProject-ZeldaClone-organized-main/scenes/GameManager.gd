extends Node

# Persistent game state carried between rooms.
# Add this as an Autoload in Project Settings -> Autoload.

var player_health: int = 3
var player_max_health: int = 3
var fireball_ready: bool = true
var rooms_cleared: Array[String] = []

func reset_game() -> void:
	player_health = player_max_health
	fireball_ready = true
	rooms_cleared.clear()
