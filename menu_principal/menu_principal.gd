extends Control
@onready var gamePlay = preload("res://main_scene.tscn")



func _on_start_btn_button_down() -> void:
	get_tree().change_scene_to_packed(gamePlay)


func _on_quit_btn_button_down() -> void:
	get_tree().quit()
