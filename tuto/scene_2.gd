## @class_doc
## @description Gestionnaire d'interface pour le menu de transition du tutoriel.
## Permet de lancer la scene principale du jeu ou de revenir a l'etape precedente.
## @tags ui, navigation, tutorial
extends Control

## @onready_doc
## @description Chemin vers la scene principale de gameplay.
## @tags nodes, scene, path
@onready var gamePlay:String = "res://Scenes/main_scene.tscn"

## @func_doc
## @description Appele lors de l'appui sur le bouton Start.
## Charge la scene principale definie dans la variable gamePlay.
## @tags ui, navigation
func _on_start_button_down() -> void:
	scene_manager.go_to_scene(gamePlay)

## @func_doc
## @description Appele lors de l'appui sur le bouton Precedant.
## Retourne a la scene precedemment enregistree dans l'historique du scene_manager.
## @tags ui, navigation
func _on_precedant_button_down() -> void:
	scene_manager.go_back()
