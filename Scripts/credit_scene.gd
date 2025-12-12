## @class_doc
## @description Gestionnaire de la scene des credits.
## Ce script est responsable du chargement et de l'affichage du contenu
## du fichier Credits.txt dans un RichTextLabel, et de la gestion du retour au menu.
## @tags ui, scene, credits, file_io

extends Control

## @const_doc
## @description Chemin du fichier texte contenant le contenu des credits.
## Le fichier doit etre au format BBCode pour un affichage correct dans le RichTextLabel.
## @tags config, path, file_io
const CREDITS_TEXT_FILE = "res://Credits.txt"

## @onready_doc
## @description Reference au RichTextLabel utilise pour afficher le contenu des credits.
## @tags nodes, ui
@onready var rich_text_label = $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel

## @func_doc
## @description Initialisation de la scene.
## Verifie l'existence du fichier Credits.txt. S'il existe, tente de l'ouvrir
## et d'inserer son contenu dans le RichTextLabel. Affiche des messages d'erreur si le fichier
## est manquant ou inaccessible.
## @tags init, file_io
func _ready():
	
	# Verification de l'existence du fichier
	if FileAccess.file_exists(CREDITS_TEXT_FILE):
		
		# Tente d'ouvrir le fichier en mode lecture
		var file = FileAccess.open(CREDITS_TEXT_FILE, FileAccess.READ)
		
		if file:
			# Lit tout le contenu et l'assigne au RichTextLabel (interprete le BBCode)
			rich_text_label.bbcode_text = file.get_as_text()
			file.close()
		else:
			# Cas d'echec d'ouverture
			rich_text_label.text = "ERREUR : Fichier Credits.txt trouve, mais impossible de l'ouvrir."
			
	else:
		# Cas ou le fichier est manquant
		rich_text_label.text = "ERREUR : Fichier Credits.txt manquant."

## @func_doc
## @description Appele lorsque le bouton 'Retour' est presse.
## Change la scene active pour revenir au Menu Principal.
## @tags ui, navigation
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
