extends Control

@onready var gamePlay:String = "res://Scenes/Main.tscn"


func _on_start_button_down() -> void:
	scene_manager.go_to_scene(gamePlay)


func _on_precedant_button_down() -> void:
	scene_manager.go_back()
