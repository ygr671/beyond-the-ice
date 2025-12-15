## @class_doc
## @description Gestionnaire de la barre de chargement pour les commandes de meubles.
## Ce script gere le processus de commande, y compris la mise en pause/reprise de la minuterie
## en fonction du cycle jour/nuit et le calcul probabiliste du succes/echec du restockage.
## @tags ui, inventory, timer, game_logic

extends Node

## @const_doc
## @description Duree fixe (en secondes) necessaire pour completer une commande.
## @tags config, time
const WORK_DURATION: float = 15.0 

# --- References de Noeuds (OnReady) ---
## @onready_doc
## @description Reference au noeud Timer utilise pour suivre le temps de travail reel.
## @tags nodes, timer
@onready var fill_timer: Timer = $"Timer"

## @onready_doc
## @description Reference a la ProgressBar qui visualise la progression de la commande.
## @tags nodes, ui
@onready var progress_bar: ProgressBar = $"charging_bar_furniture"

## @onready_doc
## @description Label affiche en cas de succes de la commande.
## @tags nodes, ui
@onready var succes: Label = $"succes"

## @onready_doc
## @description Label affiche en cas d'echec de la commande.
## @tags nodes, ui
@onready var failure: Label = $"failure"

## @onready_doc
## @description Liste des objets dans l'inventaire pour la mise a jour de l'affichage du stock.
## @tags nodes, ui
@onready var item_list: ItemList = $"../ui_inventory/Panel/ItemList"

## @onready_doc
## @description Conteneur du bouton de commande qui est cache pendant le travail.
## @tags nodes, ui
@onready var button_order: PanelContainer =$"../OrderMenu"

## @var_doc
## @description Reference a la liste de meubles geree par le player_controller.
## @tags data
var furniture_list = player_controller.furniture_list

## @var_doc
## @description Etat booleen indiquant si la barre de chargement est en cours de remplissage.
## @tags state, timer
var is_filling: bool = false

## @var_doc
## @description Temps restant sur le minuteur au moment ou la progression a ete mise en pause.
## Utilise pour la reprise du travail.
## @tags state, timer
var paused_time_left: float = 0.0

## @func_doc
## @description Initialisation du gestionnaire.
## Connecte au signal "furniture_ordered" du PlayerController et initialise le generateur aleatoire.
## @tags init, core
func _ready():
	# Nécessite que 'player_controller' soit défini et accessible globalement
	player_controller.connect("furniture_ordered", Callable(self, "_on_furniture_ordered"))
	randomize()

## @func_doc
## @description Traitement de la logique de jeu par frame.
## Gere la mise en pause/reprise du travail en fonction du cycle jour/nuit
## et met a jour la valeur de la barre de progression.
## @param _delta: float Temps ecoule depuis la derniere frame (non utilise).
## @return void
## @tags core, timer, ui
func _process(_delta: float):
	# Mise en pause si le travail est en cours et que ce n'est pas le jour
	if is_filling and not player_controller.is_day:
		pause_filling()

	# Reprise du travail si la progression etait en pause et que c'est le jour
	if not is_filling and paused_time_left > 0.0 and player_controller.is_day:
		resume_filling()

	# Mise a jour visuelle de la barre de progression
	if is_filling:
		var temps_reel_ecoule = progress_bar.max_value - fill_timer.get_time_left()
		progress_bar.value = temps_reel_ecoule

## @func_doc
## @description Met en pause le minuteur de travail.
## Sauvegarde le temps restant et arrete le Timer.
## @tags timer, state
func pause_filling():
	if is_filling:
		paused_time_left = fill_timer.get_time_left()
		fill_timer.stop()
		is_filling = false
		
## @func_doc
## @description Reprend le minuteur de travail a partir du temps mis en pause.
## Redemarre le Timer et reinitialise 'paused_time_left'.
## @tags timer, state
func resume_filling():
	if paused_time_left > 0.0:
		fill_timer.start(paused_time_left)
		is_filling = true
		paused_time_left = 0.0
		
## @func_doc
## @description Fonction asynchrone pour simuler le temps de travail.
## Le temps ne s'ecoule que lorsque player_controller.is_day est vrai.
## @param duration: float Duree totale de travail requise.
## @return void
## @tags timer, async
func wait_for_work_time(duration: float) -> void:
	var elapsed := 0.0

	while elapsed < duration:
		if player_controller.is_day:
			elapsed += get_process_delta_time()
		# Attend la prochaine frame de processus
		await get_tree().process_frame

## @func_doc
## @description Calcule un resultat binaire (succes/echec) en fonction d'une probabilite.
## @param success_proba: float Probabilite de succes (entre 0.0 et 1.0).
## @return int 1 pour succes, 0 pour echec.
## @tags probability, game_logic
func get_weighted_result(success_proba: float) -> int:
	var random_value: float = randf()
	return 1 if random_value < success_proba else 0

## @func_doc
## @description Appele lorsqu'un meuble est commande.
## Lance le minuteur, attend la duree de travail, calcule le resultat et met a jour l'inventaire.
## @param index: int Index du meuble commande dans la liste 'furniture_list'.
## @tags event, async, game_logic
func _on_furniture_ordered(index: int):
	var rand
	start_filling_bar()

	await wait_for_work_time(WORK_DURATION) # Attend que le temps de travail soit ecoule

	# Logique de probabilite de succes basee sur l'heure (is_day) et la meteo (weather)
	if player_controller.is_day && player_controller.weather:
		rand = get_weighted_result(0.85) # Grande chance de succes (Jour + Bonne meteo)
	elif player_controller.is_day && !player_controller.weather:
		rand = get_weighted_result(0.50) # Chance moyenne (Jour + Mauvaise meteo)
	else :
		rand = get_weighted_result(0.0) # Echec garanti ou tres probable (Nuit)

	_on_timer_timeout(rand) # Gere l'affichage du resultat

	# Mise a jour du stock et de l'affichage de l'inventaire en cas de succes
	if rand == 1:
		furniture_list[index].stock += furniture_list[index].restock_count
		item_list.set_item_text(index, furniture_list[index].name + " (" + str(furniture_list[index].stock) + ")")

## @func_doc
## @description Initialise et demarre la barre de progression.
## Cache le bouton de commande et lance le Timer.
## @tags ui, timer
func start_filling_bar():
	button_order.hide()
	progress_bar.show()
	progress_bar.value = 0.0
	is_filling = true
	paused_time_left = 0.0
	fill_timer.start(WORK_DURATION) 
	
## @func_doc
## @description Appele a la fin du temps de travail pour afficher le resultat.
## Gere l'affichage des labels 'succes' ou 'failure' pendant 2 secondes.
## @param random: int Le resultat du calcul de probabilite (1 pour succes, 0 pour echec).
## @tags ui, timer, cleanup
func _on_timer_timeout(random: int):
	is_filling = false
	progress_bar.value = progress_bar.max_value
	progress_bar.hide()
	progress_bar.value = progress_bar.min_value
	
	# Affichage du resultat
	if random == 1:
		succes.show()
	else:
		failure.show()
		
	button_order.show()
	
	# Temporisation de l'affichage
	await get_tree().create_timer(2.0).timeout

	# Masquage du resultat
	if random == 1:
		succes.hide()
	else:
		failure.hide()
