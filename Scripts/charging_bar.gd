extends Node

# =========================================================
# CONSTANTES
# =========================================================
const WORK_DURATION: float = 15.0 

# =========================================================
# VARIABLES & NODES
# =========================================================
@onready var fill_timer: Timer = $"Timer"
@onready var progress_bar: ProgressBar = $"charging_bar_furniture"
@onready var succes: Label = $"succes"
@onready var failure: Label = $"failure"
@onready var item_list: ItemList = $"../ui_inventory/Panel/ItemList"


var furniture_list = player_controller.furniture_list

var is_filling: bool = false
var paused_time_left: float = 0.0


func _ready():
	player_controller.connect("furniture_ordered", Callable(self, "_on_furniture_ordered"))
	randomize()


func _process(_delta: float):
	# --- Pause automatique la nuit ---
	if is_filling and not player_controller.is_day:
		pause_filling()

	# --- Reprise automatique le jour ---
	if not is_filling and paused_time_left > 0.0 and player_controller.is_day:
		resume_filling()

	# --- Mise à jour de la barre ---
	if is_filling:
		var temps_reel_ecoule = progress_bar.max_value - fill_timer.get_time_left()
		progress_bar.value = temps_reel_ecoule


# ---------------------------------------------------------
#         Gestion du système jour/nuit (pause/reprise)
# ---------------------------------------------------------

func pause_filling():
	if is_filling:
		paused_time_left = fill_timer.get_time_left()
		fill_timer.stop()
		is_filling = false
		
	


func resume_filling():
	if paused_time_left > 0.0:
		fill_timer.start(paused_time_left)
		is_filling = true
		paused_time_left = 0.0
		



# ---------------------------------------------------------
#     Attente qui se met en PAUSE la nuit automatiquement
# ---------------------------------------------------------

func wait_for_work_time(duration: float) -> void:
	var elapsed := 0.0

	while elapsed < duration:
		if player_controller.is_day:
			elapsed += get_process_delta_time()
		await get_tree().process_frame


# ---------------------------------------------------------
#                 Logique de commande meuble
# ---------------------------------------------------------

func get_weighted_result(success_proba: float) -> int:
	var random_value: float = randf()
	return 1 if random_value < success_proba else 0


func _on_furniture_ordered(index: int):
	var rand
	start_filling_bar()

	# Attente qui se met en pause la nuit
	await wait_for_work_time(WORK_DURATION) # Utilise la constante

	# Détermination du résultat
	# Note : Le temps de travail étant fini, le is_day de cette ligne est celui à la fin du travail.
	if player_controller.is_day && player_controller.weather:
		rand = get_weighted_result(0.85)
	elif player_controller.is_day && !player_controller.weather:
		rand = get_weighted_result(0.50)
	elif !player_controller.is_day && player_controller.weather:
		rand = get_weighted_result(0.60)
	else :
		rand = get_weighted_result(0.10)

	_on_timer_timeout(rand)

	# Mise à jour stock si succès
	if rand == 1:
		furniture_list[index].stock += 1
		item_list.set_item_text(index, furniture_list[index].name + " (" + str(furniture_list[index].stock) + ")")


# ---------------------------------------------------------
#                     Barre de progression
# ---------------------------------------------------------

func start_filling_bar():
	progress_bar.show()
	progress_bar.value = 0.0
	is_filling = true
	paused_time_left = 0.0
	fill_timer.start(WORK_DURATION) # Démarre le timer avec la durée de travail
	



func _on_timer_timeout(random: int):
	is_filling = false
	progress_bar.value = progress_bar.max_value
	progress_bar.hide()
	progress_bar.value = progress_bar.min_value

	if random == 1:

		succes.show()
	else:

		failure.show()
		
	await get_tree().create_timer(2.0).timeout

	if random == 1:
		succes.hide()
	else:
		failure.hide()
