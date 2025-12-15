## @class_doc
## @description Gestionnaire d'interface utilisateur pour la barre de progression de la satisfaction globale.
## Ce script calcule la moyenne de satisfaction de toutes les pieces (stockee dans player_controller.room_satisfaction)
## et met a jour la ProgressBar de maniere fluide a l'aide d'une animation (Tween).
## @tags ui, satisfaction, progress_bar, tween, core

extends Control

## @onready_doc
## @description Reference a la ProgressBar de l'interface utilisateur.
## @tags nodes, ui
@onready var bar = $VBoxContainer/ProgressBar

## @var_doc
## @description Dernière valeur cible de la moyenne de satisfaction.
## Utilisee pour eviter de relancer inutilement l'animation (Tween) si la valeur n'a pas change.
## @tags state, optimization
var derniere_cible: float = -1.0 

## @func_doc
## @description Fonction de mise a jour par frame (delta non utilise).
## Appelle la fonction principale d'actualisation de la barre.
## @param _delta: float Temps ecoule depuis la derniere frame (ignore).
## @tags core, update
func _process(_delta: float) -> void:
	actualise()

## @func_doc
## @description Calcule la moyenne de satisfaction de toutes les pieces et met a jour la barre.
## Utilise un Tween pour animer la transition de valeur, assure la securite contre la division par zero
## et optimise en ne lancant le Tween que si la valeur a reellement change.
## @return void
## @tags core, calculation, animation
func actualise() -> void:
	# 1. CORRECTION MATH : Initialisation de la somme
	var total: float = 0.0
	var nombre_pieces = player_controller.room_satisfaction.size()
	
	# Sécurité : Si la liste est vide, on évite la division par zéro et on met la barre a zéro
	if nombre_pieces == 0:
		bar.value = 0
		return

	# Calcul de la somme totale
	for i in player_controller.room_satisfaction:
		total += i
	
	# Calcul de la vraie moyenne
	var moyenne_actuelle = total / nombre_pieces
	
	# 2. CORRECTION TWEEN : On lance l'animation SEULEMENT si la valeur a changé
	# is_equal_approx est utilise pour comparer les nombres flottants
	if not is_equal_approx(moyenne_actuelle, derniere_cible):
		derniere_cible = moyenne_actuelle
		
		# Création et démarrage de l'animation de transition (Tween)
		var tween = create_tween()
		tween.tween_property(bar, "value", moyenne_actuelle, 0.4).set_trans(Tween.TRANS_CUBIC)
