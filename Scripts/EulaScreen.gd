## @class_doc
## @description Gestionnaire de la scene d'Accord de Licence Utilisateur Final (EULA).
## Ce script charge le texte de la EULA a partir d'un fichier, gere l'activation du bouton d'acceptation
## via la case a cocher, et enregistre l'acceptation dans le fichier de configuration utilisateur.
## @tags ui, scene, legal, init

extends Control

## @const_doc
## @description Chemin du fichier de configuration utilisateur pour les sauvegardes et parametres.
## @tags config, path
const SETTINGS_PATH = "user://game_settings.cfg"
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const EULA_TEXT_FILE = "user://legal/EULA.txt" # Fichier texte contenant la EULA

## @const_doc
## @description Chemin de la scene du Menu Principal.
## @tags scene, path
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"

## @const_doc
## @description Chemin du fichier texte contenant la EULA (format BBCode recommande).
## @tags config, path, file_io
const EULA_TEXT_FILE = "res://EULA.txt" 

# --- References de Noeuds (OnReady) ---
## @onready_doc
## @description Reference au bouton d'acceptation de la EULA. Initialement desactive.
## @tags nodes, ui
@onready var accept_button = $MarginContainer/VBoxContainer/HBoxContainer/AcceptButton

## @onready_doc
## @description Reference a la case a cocher (CheckBox) qui controle l'activation du bouton d'acceptation.
## @tags nodes, ui
@onready var checkbox = $MarginContainer/VBoxContainer/CheckBox

## @onready_doc
## @description Reference au RichTextLabel utilise pour afficher le texte de la EULA.
## @tags nodes, ui
@onready var rich_text_label = $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel

## @func_doc
## @description Initialisation de la scene.
## Charge le contenu du fichier EULA.txt. Configure l'etat initial du bouton d'acceptation (desactive)
## et connecte les signaux des boutons et de la case a cocher.
## @tags init, core, file_io
func _ready():
	# Chargement du fichier EULA.txt
	if FileAccess.file_exists(EULA_TEXT_FILE):
		var file = FileAccess.open(EULA_TEXT_FILE, FileAccess.READ)
		if file:
			rich_text_label.bbcode_text = file.get_as_text()
			file.close()
		else:
			rich_text_label.text = "ERREUR : Fichier EULA.txt trouve, mais impossible de l'ouvrir."
	else:
		rich_text_label.text = "ERREUR : Fichier EULA.txt manquant."
		
	# Configuration initiale et connexions des signaux
	accept_button.disabled = true
	checkbox.toggled.connect(_on_checkbox_toggled)

	accept_button.pressed.connect(_on_accept_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

## @func_doc
## @description Appele lorsque l'etat de la case a cocher change.
## Active ou desactive le bouton d'acceptation en fonction de l'etat de la case.
## @param is_checked: bool Vrai si la case est cochee, faux sinon.
## @tags ui, event
func _on_checkbox_toggled(is_checked):
	accept_button.disabled = not is_checked

## @func_doc
## @description Appele lorsque le bouton 'Quitter' est presse.
## Ferme l'application.
## @tags ui, system
func _on_quit_pressed():
	get_tree().quit()

## @func_doc
## @description Appele lorsque le bouton 'Accepter' est presse.
## Enregistre le statut d'acceptation de la EULA dans le fichier de configuration utilisateur
## et change la scene vers le Menu Principal.
## @tags ui, legal, file_io, navigation
func _on_accept_pressed():
	var config = ConfigFile.new()
	# Charge le fichier (ou le cree si non existant)
	config.load(SETTINGS_PATH) 
	# Definit la valeur d'acceptation
	config.set_value("legal", "eula_accepted", true)
	# Sauvegarde la configuration
	config.save(SETTINGS_PATH)
	
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
