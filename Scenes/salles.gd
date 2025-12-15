## @class_doc
## @description Controleur de l'environnement gerant la bascule entre le cycle Jour et Nuit.
## Utilise des animations (Tween) pour une transition fluide des proprietes de la lumiere
## directionnelle (DirectionalLight3D) et de l'eclairage ambiant (WorldEnvironment).
## @tags core, environment, lighting, animation, 3d

extends Node3D

## @onready_doc
## @description Reference a la lumiere DirectionalLight3D (le soleil ou la lune).
## @tags nodes, lighting
@onready var sun_light = $"DirectionalLight3D" 

## @onready_doc
## @description Reference au nœud WorldEnvironment.
## @tags nodes, environment
@onready var world_environment = $"WorldEnvironment" 

## @onready_doc
## @description Reference directe a la ressource Environment pour en animer les proprietes.
## @tags nodes, resource
@onready var environment_resource = world_environment.environment 

## @var_doc
## @description Etat actuel: Jour (true) ou Nuit (false).
## @tags state, time
var is_day: bool = true

# --- Variables de Jour ---
## @const_doc
## @description Couleur du soleil (chaude).
const SUN_COLOR_DAY := Color(1.0, 0.9, 0.8) 
## @const_doc
## @description Intensite du soleil.
const SUN_ENERGY_DAY: float = 2.0
## @const_doc
## @description Intensite de la lumiere ambiante pendant le jour.
const AMBIENT_ENERGY_DAY: float = 1.0

# --- Variables de Nuit ---
## @const_doc
## @description Couleur de la lune (froide).
const SUN_COLOR_NIGHT := Color(0.1, 0.1, 0.2) 
## @const_doc
## @description Intensite de la lune (tres faible).
const SUN_ENERGY_NIGHT: float = 0.05
## @const_doc
## @description Intensite de la lumiere ambiante pendant la nuit.
const AMBIENT_ENERGY_NIGHT: float = 0.05 

# --- Paramètres de Transition ---
## @const_doc
## @description Duree de la transition Jour/Nuit en secondes.
const TRANSITION_SPEED: float = 0.2 

## @func_doc
## @description Bascule l'environnement entre les configurations Jour et Nuit.
## Anime la couleur, l'energie et la rotation du soleil, ainsi que l'energie ambiante.
## @return void
## @tags core, environment, animation
func toggle_day_night():
	is_day = !is_day
	
	var target_sun_color: Color
	var target_sun_energy: float
	var target_ambient_energy: float
	var target_rotation: Vector3
	
	# 1. Définir les valeurs cibles (Jour ou Nuit)
	if is_day:
		target_sun_color = SUN_COLOR_DAY
		target_sun_energy = SUN_ENERGY_DAY
		target_ambient_energy = AMBIENT_ENERGY_DAY
		target_rotation = Vector3(deg_to_rad(45), deg_to_rad(45), 0) # Position Jour
	else:
		target_sun_color = SUN_COLOR_NIGHT
		target_sun_energy = SUN_ENERGY_NIGHT
		target_ambient_energy = AMBIENT_ENERGY_NIGHT
		target_rotation = Vector3(deg_to_rad(225), deg_to_rad(45), 0) # Position Nuit (hors champ)

	# 2. Lancement des animations de transition (Tween)
	
	# Animation de la lumiere solaire (Couleur et Intensite)
	var tween_light = create_tween()
	tween_light.set_parallel(true)
	tween_light.tween_property(sun_light, "light_color", target_sun_color, TRANSITION_SPEED)
	tween_light.tween_property(sun_light, "light_energy", target_sun_energy, TRANSITION_SPEED)
	
	# Animation de la rotation du soleil (angle)
	var tween_rotation = create_tween()
	tween_rotation.tween_property(sun_light, "rotation", target_rotation, TRANSITION_SPEED)

	# Animation de la lumiere ambiante
	var tween_ambient = create_tween()
	tween_ambient.tween_property(environment_resource, "ambient_light_energy", target_ambient_energy, TRANSITION_SPEED)
