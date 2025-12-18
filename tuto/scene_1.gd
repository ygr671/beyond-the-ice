## @class_doc
## @description Gestionnaire d'interface pour la navigation entre les scenes du tutoriel.
## @tags ui, navigation, tutorial
extends Control

## @func_doc
## @description Appele lors de l'appui sur le bouton Suivant.
## Utilise le gestionnaire de scenes pour charger la seconde partie du tutoriel.
## @tags ui, navigation
func _on_suivant_button_down() -> void:
	scene_manager.go_to_scene("res://tuto//scene2.tscn")
