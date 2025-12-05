extends Node3D


@onready var water_node = $LowPolyWater 
@onready var worldenv = $WorldEnvironment
@onready var iceberg_node = $Iceberg as Iceberg_controller

var is_day: bool = true

const WATER_COLOR_DAY := Color(1.0, 1.0, 1.0)   
const WATER_COLOR_NIGHT := Color(0.0, 0.0, 0.0)
const TRANSITION_SPEED: float = 1.5

# AJOUT : Couleurs pour l'iceberg
const ICEBERG_COLOR_DAY := Color(0.8, 0.9, 1.0) # Blanc/Bleu clair
const ICEBERG_COLOR_NIGHT := Color(0.3, 0.5, 0.7) # Bleu foncé/Gris



func _ready():
	
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
	
		print("ERREUR CRITIQUE: Le nœud d'eau ($LowPolyWater) est trouvé, mais le script Low_poly_water.gd est manquant ou n'a pas la fonction 'set_water_color_target'.")
	
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(ICEBERG_COLOR_DAY)



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
		target_iceberg_color = ICEBERG_COLOR_NIGHT # AJOUT
		target_env_energy = 0.2 # Valeur faible pour la nuit

	# Délègue la tâche d'animation au script de l'eau
	water_node.set_water_color_target(target_water_color)
	
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(target_iceberg_color)
	
	if worldenv:
		var tween_env = create_tween()
		
		# On anime la propriété 'environment:background_energy_multiplier'
		tween_env.tween_property(
			worldenv.environment, 
			"background_energy_multiplier", 
			target_env_energy, 
			TRANSITION_SPEED
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Fonction de connexion du Bouton UI (appelée par le script UI)
func _on_cycle_pressed():
	toggle_day_night()
