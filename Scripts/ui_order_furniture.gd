## @class_doc
## @description Gestionnaire d'interface utilisateur pour la commande de nouveaux meubles.
## Ce script gère l'affichage du menu de commande et impose une restriction :
## le joueur ne peut avoir qu'une seule commande en cours de traitement a la fois (processing).
## Il est responsable de l'emission du signal de debut de commande.
## @tags ui, inventory, order, restriction, time

extends Control

## @onready_doc
## @description Reference au nœud de controle principal de ce menu de commande.
## @tags nodes, ui
@onready var order_furniture = $"."

## @onready_doc
## @description Reference au sous-menu de selection de couleur.
## @tags nodes, ui
@onready var color_menu = $"../ui_color_selection"

## @onready_doc
## @description Reference au panneau d'inventaire.
## @tags nodes, ui
@onready var inventory_menu = $"../ui_inventory"

## @onready_doc
## @description Reference a la barre de chargement (non utilisee directement, mais presente).
## @tags nodes, ui
@onready var charging_bar = $"../ui_charging_bar"

## @onready_doc
## @description Reference a la liste d'objets disponibles a la commande.
## @tags nodes, ui
@onready var item_list = $"../ui_order_furniture/Panel/ItemList"

## @onready_doc
## @description Reference au Label d'erreur affiche en cas de commande en cours.
## @tags nodes, ui
@onready var err_message = $"../ui_order_furniture/err_message"

## @var_doc
## @description Indicateur booleen: True si une commande est deja en cours de traitement.
## @tags state, restriction
var processing: bool = false

## @func_doc
## @description Appelé lors de l'appui sur le bouton d'ouverture du menu de commande.
## Affiche le menu de commande et masque les autres sous-menus de l'UI.
## @return void
## @tags ui, navigation
func _on_button_order_pressed() -> void:
	order_furniture.show()
	color_menu.hide()
	inventory_menu.hide()

## @func_doc
## @description Appelé lorsqu'un element de la liste est selectionne pour la commande.
## Verifie si une commande est en cours, sinon, demarre le processus de commande (15.0s).
## @param index: int Index du meuble commande dans la liste.
## @return void
## @tags ui, core, signal, time
func _on_item_list_item_selected(index: int) -> void:
	print(processing) # Debug
	
	# 1. Verification de la restriction
	if processing:
		item_list.deselect_all()
		err_message.show()
		# Affiche le message d'erreur pendant 2 secondes
		await get_tree().create_timer(2.0).timeout
		err_message.hide()
		return
		
	# 2. Demarrage du traitement
	processing = true
	order_furniture.hide()
	item_list.deselect_all()
	
	# Emission du signal pour que la barre de progression (charging_bar) demarre
	player_controller.emit_signal("furniture_ordered", index)
	
	# 3. Simulation du temps de livraison (15 secondes)
	await get_tree().create_timer(15.0).timeout
	
	# 4. Fin du traitement
	processing = false
	# NOTE: La logique d'ajout reel du meuble au stock se trouve probablement
	# dans le script charge par le signal 'furniture_ordered' (ex: charging_bar.gd).

## @func_doc
## @description Appelé lors de l'appui sur un bouton générique de fermeture/validation du menu.
## Masque le menu de commande de meubles.
## @return void
## @tags ui
func _on_button_pressed() -> void:
	order_furniture.hide()
