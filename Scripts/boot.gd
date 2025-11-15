extends Node

const SETTINGS_PATH = "user://game_settings.cfg"
const EULA_SCENE = "res://Scenes/EulaScreen.tscn" # Mettez le chemin vers votre scène EULA
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn" # Mettez le chemin vers votre menu

func _ready():
	# 1. Charger le fichier de config
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)

	# 2. Vérifier la valeur
	var eula_accepted = false
	if err == OK: # Si le fichier existe et est lisible
		# "get_value" prend une valeur par défaut (false) si la clé n'existe pas
		eula_accepted = config.get_value("legal", "eula_accepted", false)

	# 3. Décider où aller
	if not eula_accepted:
		# L'EULA n'a jamais été accepté -> Aller à l'écran EULA
		get_tree().call_deferred("change_scene_to_file", EULA_SCENE)
	else:
		# L'EULA a déjà été accepté -> Aller au menu principal
		get_tree().call_deferred("change_scene_to_file", MAIN_MENU_SCENE)
