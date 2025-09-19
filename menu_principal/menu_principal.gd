extends Control
@onready var gamePlay = preload("res://main_scene.tscn")
@onready var tuto = preload("res://tuto//scene1.tscn")



func _on_start_btn_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(gamePlay)


func _on_quit_btn_button_down() -> void:
	get_tree().quit()


func _on_tutorial_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(tuto)
	
