## @class_doc
## @description Gestionnaire de fin de mission et d'envoi de score.
## Ce script gere l'affichage du formulaire de fin de partie, le calcul du score total 
## base sur la satisfaction des salles, et la communication avec l'API REST.
## @tags ui, core, network, score
extends Control

## @onready_doc
## @description Référence au formulaire de confirmation de fin de partie
## @tags nodes, ui
@onready var form_end_game = $"../ui_confirmation_end"

## @onready_doc
## @description Référence au nœud de l'interface de sélection/inventaire (ce nœud lui-même).
## @tags nodes, ui
@onready var item_list = $"../ui_inventory"

## @onready_doc
## @description Référence au nœud de l'interface de sélection de couleur.
## @tags nodes, ui
@onready var color_menu = $"../ui_color_selection"

## @onready_doc
## @description Référence au nœud de l'interface de commande de meubles.
## @tags nodes, ui
@onready var order_menu = $"../ui_order_furniture"

## @onready_doc
## @description Référence au panel de l'interface de commande de meubles.
## @tags nodes, ui
@onready var inventory_menu = $"../ui_inventory"

## @onready_doc
## @description Référence au noeud de l'HTTPRequest pour faire des requêtes à l'API
## @tags node, ui
@onready var http_request = $"../../../../HTTPRequest"

## @onready_doc
## @description Référence au champ de pseudonyme
## @tags node, ui
@onready var username = $"Panel/username_prompt"

## @onready_doc
## @description Référence au bouton "oui"
## @tags node, ui
@onready var yes_button = $"Panel/yes"


# TODO : commenter
const API_ENDPOINT = "http://bore.pub:9520/api/players"


## @func_doc
## @description Affiche le formulaire de confirmation de fin de partie.
## @tags ui, navigation
func _on_button_end_mission_pressed() -> void:
	color_menu.hide()
	order_menu.hide()
	item_list.hide()
	inventory_menu.hide()
	form_end_game.show()
	
	
## @func_doc
## @description Cache le formulaire de confirmation de fin de partie.
## @tags ui, navigation
func _on_button_no_pressed() -> void:
	form_end_game.hide()

## @func_doc
## @description Termine la partie et redirige l'utilisateur vers le formulaire de saisie de nom d'utilisateur.
## @tags ui, navigation
func _on_button_yes_pressed() -> void:
	form_end_game.hide()
	var score = player_controller.score
	var json_data = JSON.stringify({
		"username": username.text,
		"score": score,
		"duration": player_controller.chrono
		})
		
	var headers = ["Content-Type: application/json"]
	http_request.request(API_ENDPOINT, headers, HTTPClient.METHOD_POST, json_data)

## @func_doc
## @description Vérifie si le champ de saisie du nom d'utilisateur est vide
## @tags ui
func _on_username_prompt_text_changed(new_text: String) -> void:
	var filtered_text = ""
	for i in range(new_text.length()):
		var char_code = new_text.unicode_at(i)
		if (char_code >= 48 and char_code <= 57) or (char_code >= 65 and char_code <= 90) or (char_code >= 97 and char_code <= 122): 
			filtered_text += char(char_code)

	if filtered_text != new_text:
		username.text = filtered_text
		username.caret_column = filtered_text.length()
		
	yes_button.disabled = true if filtered_text.is_empty() else false
	 
