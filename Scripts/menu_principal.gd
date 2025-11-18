extends Control

@onready var SceneACharger:String = "res://Scenes/main_scene.tscn"
	
func _on_start_btn_button_down() -> void:
	#await get_tree().create_timer(1).timeout
	scene_manager.go_to_scene(SceneACharger)  


func _on_quit_btn_button_down() -> void:
	get_tree().quit()


func _on_tutorial_button_down() -> void:
	scene_manager.go_to_scene("res://tuto//scene1.tscn")  
	


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CreditScene.tscn")
