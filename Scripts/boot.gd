extends Node

const SETTINGS_PATH = "user://game_settings.cfg"
const EULA_SCENE = "res://Scenes/EulaScreen.tscn"
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"

func _ready():
	print(OS.get_user_data_dir())
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	var eula_accepted = false
	if err == OK:
		eula_accepted = config.get_value("legal", "eula_accepted", false)

	if not eula_accepted:
		call_deferred("_go_to_eula")
	else:
		call_deferred("_go_to_main_menu")

func _go_to_eula():
	get_tree().change_scene_to_file(EULA_SCENE)

func _go_to_main_menu():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
