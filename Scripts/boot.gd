## @class_doc
## @description Gestionnaire de demarrage de l'application.
## Ce script verifie si l'utilisateur a accepte l'Accord de Licence Utilisateur Final (EULA).
## Il dirige ensuite le joueur soit vers l'ecran EULA, soit vers le Menu Principal.
## Ce noeud est destine a etre le premier noeud charge dans l'arborescence du jeu.
## @tags core, init, boot, legal

extends Node
class_name BootManager

## @const_doc
## @description Chemin du fichier de configuration utilisateur pour les sauvegardes et parametres.
## Le fichier est stocke dans le dossier utilisateur du systeme d'exploitation.
## @tags config, path
const SETTINGS_PATH = "user://game_settings.cfg"

## @const_doc
## @description Chemin de la scene de l'Accord de Licence Utilisateur Final (EULA).
## @tags scene, path
const EULA_SCENE = "res://Scenes/EulaScreen.tscn"

## @const_doc
## @description Chemin de la scene du Menu Principal.
## @tags scene, path
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"

## @func_doc
## @description Fonction d'initialisation du noeud.
## Elle tente de charger le fichier de configuration et verifie l'etat d'acceptation de l'EULA.
## La redirection vers la scene appropriee est declenchee de maniere differee.
## @tags init, core
func _ready():
	print(OS.get_user_data_dir())
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	var eula_accepted = false
	
	# Si le fichier de configuration a pu etre charge (err == OK), on lit le flag.
	if err == OK:
		# Recupere la valeur "eula_accepted" dans la section "legal". Faux par defaut.
		eula_accepted = config.get_value("legal", "eula_accepted", false)

	# call_deferred est utilise pour s'assurer que le changement de scene se produit
	# apres que le noeud actuel ait termine sa phase _ready.
	if not eula_accepted:
		call_deferred("_go_to_eula")
	else:
		call_deferred("_go_to_main_menu")

## @func_doc
## @description Fonction interne appellee pour changer la scene vers l'ecran EULA.
## @tags scene, navigation
func _go_to_eula():
	get_tree().change_scene_to_file(EULA_SCENE)

## @func_doc
## @description Fonction interne appellee pour changer la scene vers le Menu Principal.
## @tags scene, navigation
func _go_to_main_menu():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
