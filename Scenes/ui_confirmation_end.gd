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
@onready var http_request = $"../../HTTPRequest"


# TODO : commenter
const API_ENDPOINT = "https://127.0.0.1:8000/api/test"


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
	# TODO : bouger cette partie vers le formulaire de saisie de nom d'utilisateur
	var json = JSON.stringify([{}]) # TODO : remplir les données avec les données de la partie ici (nom d'utilisateur + score).
	var headers = ["Content-Type: application/json"]
	http_request.request(API_ENDPOINT, headers, HTTPClient.METHOD_POST, json)
