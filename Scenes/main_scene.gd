extends Node3D

# =========================================================
# CONSTANTES JOUR/NUIT
# =========================================================
const WATER_COLOR_DAY := Color(1.0, 1.0, 1.0)    
const WATER_COLOR_NIGHT := Color(0.0, 0.0, 0.0)
const TRANSITION_SPEED: float = 1.5
const ICEBERG_COLOR_DAY := Color(0.8, 0.9, 1.0)
const ICEBERG_COLOR_NIGHT := Color(0.3, 0.5, 0.7)

# =========================================================
# NODES
# =========================================================
@onready var worldenv = $WorldEnvironment
@onready var iceberg_node = $Iceberg as Iceberg_controller
@onready var water_node = $LowPolyWater
@onready var snow_node = $Snow
@onready var ui_charging_bar = $Salles/salon/ui_Salon/ui_charging_bar

# =========================================================
# VARIABLES DE SCENE
# =========================================================
var is_day: bool = true
var is_good_weather: bool = true
var is_cracking: bool = false # État actuel du crépitement
var time_since_last_check: float = 0.0 # Minuteur scripté pour la météo



func _ready():
	
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
		print("ERREUR CRITIQUE: Le nœud d'eau ($LowPolyWater) est trouvé, mais le script Low_poly_water.gd est manquant ou n'a pas la fonction 'set_water_color_target'.")
	
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(ICEBERG_COLOR_DAY)




# ---------------------------------------------------------
#                   SYSTÈME JOUR/NUIT
# ---------------------------------------------------------

func toggle_day_night():
	
	if !water_node or !water_node.has_method("set_water_color_target"):
		return
		
	is_day = !is_day
	
	var target_water_color: Color
	var target_iceberg_color: Color
	var target_env_energy: float
	
	if is_day:
		target_water_color = WATER_COLOR_DAY
		target_iceberg_color = ICEBERG_COLOR_DAY
		target_env_energy = 1.0
		
	else:
		target_water_color = WATER_COLOR_NIGHT
		target_iceberg_color = ICEBERG_COLOR_NIGHT 
		target_env_energy = 0.2 

	player_controller.is_day = is_day
	water_node.set_water_color_target(target_water_color)
	
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(target_iceberg_color)
	
	if worldenv:
		var tween_env = create_tween()
		
		# Anime la propriété 'environment:background_energy_multiplier'
		tween_env.tween_property(
			worldenv.environment, 
			"background_energy_multiplier", 
			target_env_energy, 
			TRANSITION_SPEED
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func toggle_good_bad_weather():
	
	is_good_weather = !is_good_weather
	
	player_controller.weather = is_good_weather
	
	if !is_good_weather:
		water_node.animate_crackle_amount(1.5, 1.0)
		snow_node.speed_scale = 5
		print("NOT GOOD")
		
	else:
		water_node.animate_crackle_amount(0.4, 1.0)
		snow_node.speed_scale = 1
		print("GOOD")

	if not is_good_weather:
		print("ALERTE MÉTÉO : Mauvais temps (Crépitement activé)")
	else:
		print("ALERTE MÉTÉO : Retour au beau temps")
	
	
