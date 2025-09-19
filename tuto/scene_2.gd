extends Control
@onready var gamePlay = preload("res://main_scene.tscn")



func _on_start_button_down() -> void:
	await get_tree().create_timer(1).timeout
	scene_manager.go_to_scene("res://main_scene.tscn")


func _on_precedant_button_down() -> void:
	scene_manager.go_back()
