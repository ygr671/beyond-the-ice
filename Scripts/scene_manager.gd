## @class_doc
## @description Gestionnaire de scene implémentant une navigation basée sur une pile (stack).
## Ce script permet de naviguer entre les scenes tout en conservant l'historique pour
## une fonction de retour facile, similaire à l'historique d'un navigateur web.
## Ce script est généralement configuré comme un Autoload (Singleton).
## @tags core, scene_manager, navigation, state

extends Node

## @var_doc
## @description Pile (Array) stockant les chemins des scenes precedentes.
## Permet de retracer l'historique pour la fonction de retour.
## @type Array
## @tags state, navigation
var scene_stack : Array = []

## @func_doc
## @description Charge une nouvelle scene et ajoute son chemin a la pile.
## @param new_scene_path: String Chemin de la nouvelle scene a charger (ex: "res://Scenes/MainMenu.tscn").
## @return void
## @tags navigation, core
func go_to_scene(new_scene_path: String) -> void:
	# Stocke le chemin de la nouvelle scene (qui devient la scene actuelle)
	scene_stack.append(new_scene_path) 
	get_tree().change_scene_to_file(new_scene_path)

## @func_doc
## @description Revient a la scene precedente dans la pile.
## La scene actuelle est retiree de la pile avant de charger la scene precedente.
## @return void
## @tags navigation, core
func go_back() -> void:
	# On verifie qu'il y a au moins deux elements: la scene actuelle et la scene precedente a atteindre.
	if scene_stack.size() > 1:
		# Retire la scene actuelle de la pile (celle qu'on quitte)
		scene_stack.pop_back()
		
		# Le chemin de la scene precedente est maintenant le dernier element de la pile
		var previous_path = scene_stack[scene_stack.size() - 1]
		get_tree().change_scene_to_file(previous_path)
	# Note: Si la pile contient 0 ou 1 element, aucune action n'est effectuee (on reste a l'ecran actuel).
