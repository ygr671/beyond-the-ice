## @class_doc
## @description Contrôleur de la scene 3D principale.
## Gère le cycle Jour/Nuit, la météo (bon/mauvais temps), et orchestre
## les transitions visuelles (couleur de l'eau, éclairage ambiant, neige)
## en interagissant avec les autres contrôleurs d'environnement (Iceberg, Water).
## @tags core, environment, time_management, 3d

extends Node3D

## @const_doc
## @description Couleur de l'eau pendant le jour (Blanc pur pour l'éclairage de la texture).
## @tags config, color
const WATER_COLOR_DAY := Color(1.0, 1.0, 1.0)    

## @const_doc
## @description Couleur de l'eau pendant la nuit (Noir pour simuler l'absence de lumière).
## @tags config, color
const WATER_COLOR_NIGHT := Color(0.9, 0.9, 0.9)

## @const_doc
## @description Vitesse de transition pour les animations (ex: changement de couleur de l'eau, énergie environnementale).
## @tags config, animation
const TRANSITION_SPEED: float = 1.5

## @const_doc
## @description Couleur de l'iceberg pendant le jour.
## @tags config, color
const ICEBERG_COLOR_DAY := Color(0.643, 0.812, 0.835)  # #a4cfd5

## @const_doc
## @description Couleur de l'iceberg pendant la nuit.
## @tags config, color
const ICEBERG_COLOR_NIGHT := Color(0.219, 0.351, 0.375)




## @onready_doc
## @description Reference au nœud WorldEnvironment qui controle l'eclairage ambiant et le ciel.
## @tags nodes, environment
@onready var worldenv = $WorldEnvironment

## @onready_doc
## @description Reference au contrôleur de l'iceberg (script Iceberg_controller.gd).
## @type Iceberg_controller
## @tags nodes, environment
@onready var iceberg_node = $Iceberg as Iceberg_controller
@onready var mini_iceberg = $Mini_iceberg as Mini_iceberg_controller
## @onready_doc
## @description Reference au contrôleur de l'eau (script low_poly_water.gd).
## @tags nodes, environment
@onready var water_node = $LowPolyWater

## @onready_doc
## @description Reference au nœud du systeme de particules/GPU qui gere la neige.
## @tags nodes, environment
@onready var snow_node = $Snow

## @onready_doc
## @description Reference a la barre de chargement UI (situee dans la salle du salon).
## @tags nodes, ui
@onready var ui_charging_bar = $Salles/salon/ui_Salon/ui_charging_bar

## @var_doc
## @description Etat actuel de la météo: Beau temps (true) ou Mauvais temps (false).
## @tags state, weather
var is_good_weather: bool = true

## @var_doc
## @description Indique si l'effet d'agitation de l'eau (crépitement) est actif.
## @tags state, weather
var is_cracking: bool = false

## @var_doc
## @description Minuteur pour la logique scriptée de la météo (non utilise dans le code actuel, mais reserve).
## @tags cleanup, time
var time_since_last_check: float = 0.0

## @func_doc
## @description Initialisation de la scene: met a jour la couleur initiale de l'eau et de l'iceberg.
## @tags init, core
func _ready():
	
	# Initialisation de la couleur de l'eau au Jour
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
		print("ERREUR CRITIQUE: Le nœud d'eau ($LowPolyWater) est trouvé, mais le script Low_poly_water.gd est manquant ou n'a pas la fonction 'set_water_color_target'.")
		
	# Initialisation de la couleur de l'iceberg au Jour
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(ICEBERG_COLOR_DAY)


## @func_doc
## @description Bascule l'etat entre Jour et Nuit.
## Orchestre les changements de couleur de l'eau, de l'iceberg et de l'energie environnementale.
## @return void
## @tags time, environment, animation
func toggle_day_night():
	print("\n=== toggle_day_night() appelé ===")
	
	player_controller.is_day = !player_controller.is_day
	
	var target_iceberg_color: Color
	var target_water_color: Color
	
	if player_controller.is_day:
		print("→ Transition vers JOUR")
		target_iceberg_color = ICEBERG_COLOR_DAY      # #a4cfd5
		target_water_color = WATER_COLOR_DAY
	else:
		print("→ Transition vers NUIT")
		target_iceberg_color = ICEBERG_COLOR_NIGHT    # #060f11
		target_water_color = WATER_COLOR_NIGHT
	
	# 1. Transition iceberg - CORRECTION ICI
	if iceberg_node:
		print("Changement couleur iceberg vers: ", target_iceberg_color)
		iceberg_node.set_iceberg_color(target_iceberg_color)
		mini_iceberg.set_mini_iceberg_color(target_iceberg_color)
		
	else:
		print("✗ iceberg_node est null!")
	
	# 2. Transition eau
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(target_water_color)
	
	# 3. Transition luminosité environnement
	if worldenv:
		var target_energy = 1.0 if player_controller.is_day else 0.2
		var tween = create_tween()
		tween.tween_property(
			worldenv.environment,
			"background_energy_multiplier",
			target_energy,
			TRANSITION_SPEED
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## @func_doc
## @description Bascule l'etat entre Beau temps et Mauvais temps.
## Affecte l'agitation de l'eau (animate_crackle_amount) et la vitesse de la neige.
## @return void
## @tags weather, environment, particles
func toggle_good_bad_weather():
	
	is_good_weather = !is_good_weather
	
	# Met a jour l'etat global
	player_controller.weather = is_good_weather
	
	# Ajustement de l'eau et de la neige
	if !is_good_weather:
		# Mauvais temps (agitée)
		water_node.animate_crackle_amount(1.5, 1.0) # Augmente l'agitation
		snow_node.speed_scale = 5 # Augmente la vitesse des particules de neige
		print("NOT GOOD")
		
	else:
		# Beau temps (calme)
		water_node.animate_crackle_amount(0.4, 1.0) # Normalise l'agitation
		snow_node.speed_scale = 1 # Normalise la vitesse de la neige
		print("GOOD")

	if not is_good_weather:
		print("ALERTE MÉTÉO : Mauvais temps (Crépitement activé)")
	else:
		print("ALERTE MÉTÉO : Retour au beau temps")


func _on_button_no_pressed() -> void:
	pass # Replace with function body.
