extends Node3D


@onready var water_node = $LowPolyWater 
@onready var worldenv = $WorldEnvironment

var is_day: bool = true

const WATER_COLOR_DAY := Color(1.0, 1.0, 1.0)   
const WATER_COLOR_NIGHT := Color(0.0, 0.0, 0.0)
const TRANSITION_SPEED: float = 1.5



func _ready():
	
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
	
		print("ERREUR CRITIQUE: Le nœud d'eau ($LowPolyWater) est trouvé, mais le script Low_poly_water.gd est manquant ou n'a pas la fonction 'set_water_color_target'.")



func toggle_day_night():
	
	if !water_node or !water_node.has_method("set_water_color_target"):
		return
		
	is_day = !is_day
	
	var target_water_color: Color
	var target_env_energy: float
	
	if is_day:
		target_water_color = WATER_COLOR_DAY
		target_env_energy = 1.0
		

	else:
		target_water_color = WATER_COLOR_NIGHT
		target_env_energy = 0.2 # Valeur faible pour la nuit

	player_controller.is_day = is_day
	# Délègue la tâche d'animation au script de l'eau
	water_node.set_water_color_target(target_water_color)
	
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
