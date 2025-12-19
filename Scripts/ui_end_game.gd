extends Control

@onready var score = $basePanel/panelScore/score

@onready var time = $basePanel/panelTime/tempsEcoule

func init() -> void:
	score.text = str(player_controller.score)
	time.text = format_time()

func format_time() ->String:
	var final_time: int = int(player_controller.chrono)
	
	@warning_ignore("integer_division")
	var minutes: int = final_time/60
	var secondes: int = final_time%60
	
	return "%02d:%02d" % [minutes, secondes]


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
