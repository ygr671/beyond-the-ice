## @class_doc
## @description Gestionnaire de l'interface et des interactions de l'utilisateur dans le Menu Principal.
## Ce script est attache a la scene du menu et dirige le joueur vers les differentes scenes
## (jeu principal, tutoriel, credits) ou gere la fermeture de l'application.
## @tags ui, menu, navigation, core

extends Control

## @onready_doc
## @description Chemin de la scene principale du jeu qui sera chargee lors du demarrage.
## @type String
## @tags config, scene
@onready var SceneACharger:String = "res://Scenes/main_scene.tscn"
	
## @func_doc
## @description Appele lorsque le bouton 'Demarrer' est presse (evenement button_down).
## Utilise le SceneManager pour naviguer vers la scene principale du jeu.
## @return void
## @tags ui, navigation
func _on_start_btn_button_down() -> void:
	# Ligne commente: 'await get_tree().create_timer(1).timeout' peut etre utilise pour un delai/une transition
	scene_manager.go_to_scene(SceneACharger)  

## @func_doc
## @description Appele lorsque le bouton 'Quitter' est presse (evenement button_down).
## Ferme l'application.
## @return void
## @tags ui, system
func _on_quit_btn_button_down() -> void:
	get_tree().quit()

## @func_doc
## @description Appele lorsque le bouton 'Tutoriel' est presse (evenement button_down).
## Utilise le SceneManager pour naviguer vers la premiere scene du tutoriel.
## @return void
## @tags ui, navigation
func _on_tutorial_button_down() -> void:
	scene_manager.go_to_scene("res://tuto//scene1.tscn")  
	
## @func_doc
## @description Appele lorsque le bouton 'Credits' est presse (evenement pressed).
## Change directement la scene vers la scene des credits.
## @return void
## @tags ui, navigation
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CreditScene.tscn")
