extends Control

signal dialogue_ended

@onready var label: Label = $Label
@onready var button: Button = $Button


func _ready() -> void:
	hide()
	button.pressed.connect(_on_button_pressed)


func show_dialogue(text: String) -> void:
	label.text = text
	show()
	get_tree().paused = true


func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false
	dialogue_ended.emit()
