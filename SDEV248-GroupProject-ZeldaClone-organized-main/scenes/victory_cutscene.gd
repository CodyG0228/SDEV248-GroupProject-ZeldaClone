extends Control



func _on_play_again_button_pressed():
	GameManager.reset_game() # resets health upon restart
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
