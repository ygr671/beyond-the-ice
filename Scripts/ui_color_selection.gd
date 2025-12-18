## @class_doc
## @description Gestionnaire d'interface utilisateur pour la sélection de la couleur des murs.
## Ce script permet de choisir une couleur et d'émettre le signal de changement d'environnement.
## Il applique une restriction: la couleur d'une piece ne peut etre changee qu'une seule fois.
## @tags ui, color_picker, environment, restriction

extends Control

## @onready_doc
## @description Référence au nœud de contrôle principal de ce menu de sélection de couleur.
## @tags nodes, ui
@onready var color_menu = $"."
@onready var salles = $"../../../"
@onready var intensity = $"HSlider_light _intensity"

@onready var heat = $HSlider_light_heat

var light : OmniLight3D

## @var_doc
## @description Tableau de booléens indiquant si la couleur d'une piece a deja ete changee.
## La taille (6) correspond au nombre de pieces attendues.
## @tags state, core, restriction
var already_changed = []

## @func_doc
## @description Initialisation. Redimensionne et remplit le tableau 'already_changed' à False.
## @tags init
func _ready() -> void:
	already_changed.resize(6)
	already_changed.fill(false)

## @func_doc
## @description Appelé lors de l'appui sur un bouton générique de fermeture/validation (si présent).
## Masque le menu de sélection de couleur.
## @tags ui
func _on_button_pressed() -> void:
	color_menu.hide()

# --- Fonctions de sélection de couleur ---
# Ces fonctions partagent toutes la même logique :
# 1. Vérifient si la couleur de la pièce actuelle (player_controller.current_room) a déjà été modifiée.
# 2. Si oui, masquent le menu et sortent.
# 3. Si non, marquent la pièce comme modifiée (already_changed[index] = true).
# 4. Émettent le signal "environment_changed" avec le type "color_changed" et la nouvelle couleur.
# 5. Masquent le menu.

## @func_doc
## @description Appelé lors de l'appui sur le bouton Orange.
## Emet le signal de changement de couleur avec Color.DARK_ORANGE.
## @tags ui, signal
func _on_orange_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_ORANGE)
	color_menu.hide()

## @func_doc
## @description Appelé lors de l'appui sur le bouton Rouge.
## Emet le signal de changement de couleur avec Color.DARK_RED.
## @tags ui, signal
func _on_red_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_RED)
	color_menu.hide()

## @func_doc
## @description Appelé lors de l'appui sur le bouton Vert.
## Emet le signal de changement de couleur avec Color.DARK_GREEN.
## @tags ui, signal
func _on_green_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GREEN)
	color_menu.hide()

## @func_doc
## @description Appelé lors de l'appui sur le bouton Blanc.
## Emet le signal de changement de couleur avec Color.WHITE_SMOKE.
## @tags ui, signal
func _on_white_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.WHITE_SMOKE)
	color_menu.hide()

## @func_doc
## @description Appelé lors de l'appui sur le bouton Gris.
## Emet le signal de changement de couleur avec Color.DARK_GRAY.
## @tags ui, signal
func _on_gray_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GRAY)
	color_menu.hide()

## @func_doc
## @description Appelé lors de l'appui sur le bouton Noir.
## Emet le signal de changement de couleur avec Color.DIM_GRAY.
## @tags ui, signal
func _on_black_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DIM_GRAY)
	color_menu.hide()


func _on_h_slider_light__intensity_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var value = intensity.value
		light = salles.get_child(player_controller.current_room).get_node("room_light")
		light.light_energy = remap(value, 0, 100, 0.2, 7.0)
		player_controller.emit_signal("environment_changed", "light_intensity_changed", value)


func _on_h_slider_light_heat_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var value = heat.value
		light = salles.get_child(player_controller.current_room).get_node("room_light")
		
		if value <= 20:
	# Un blanc très chaud (teinté orange) au lieu d'un rouge pur
			light.light_color = Color8(255, 200, 180) 
		elif value <= 40:
			# Un blanc crème
			light.light_color = Color8(255, 240, 220)
		elif value <= 60:
			# Blanc pur
			light.light_color = Color8(255, 255, 255)
		elif value <= 80:
			# Un blanc bleuté très léger
			light.light_color = Color8(220, 240, 255)
		else:
			# Un bleu glacier très clair
			light.light_color = Color8(180, 220, 255)
		player_controller.emit_signal("environment_changed", "light_heat_changed", value)
