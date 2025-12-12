## @class_doc
## @description Gestionnaire du panneau de contrôle principal de l'interface utilisateur (UI).
## Ce script gère l'affichage/masquage des différents sous-menus de l'UI (inventaire,
## sélection de couleur, commande de meubles) lors de l'interaction avec le bouton
## principal de l'inventaire.
## @tags ui, inventory, navigation

extends Node

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


## @func_doc
## @description Appelé lors de l'appui sur un bouton générique de fermeture/validation (si présent).
## Masque le menu de sélection/inventaire.
## @return void
## @tags ui
func _on_button_pressed() -> void:
	item_list.hide()


## @func_doc
## @description Appelé lors de l'appui sur le bouton principal de l'inventaire.
## Affiche le menu de sélection/inventaire et s'assure que les autres sous-menus sont masques.
## @return void
## @tags ui, navigation
func _on_button_inventory_pressed() -> void:
	item_list.show()
	color_menu.hide()
	order_menu.hide()
