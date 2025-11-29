extends Node3D

# Références aux nœuds
@onready var sun_light = $"DirectionalLight3D" # Remplacer par le chemin correct
@onready var world_environment = $"WorldEnvironment" # Remplacer par le chemin correct
@onready var environment_resource = world_environment.environment # Référence à la ressource Environment

# États
var is_day: bool = true

# --- Variables de Jour ---
const SUN_COLOR_DAY := Color(1.0, 0.9, 0.8) # Couleur chaude
const SUN_ENERGY_DAY: float = 2.0
const AMBIENT_ENERGY_DAY: float = 1.0

# --- Variables de Nuit ---
const SUN_COLOR_NIGHT := Color(0.1, 0.1, 0.2) # Couleur froide (lune)
const SUN_ENERGY_NIGHT: float = 0.05
const AMBIENT_ENERGY_NIGHT: float = 0.05 # Lumière ambiante très faible

# --- Paramètres de Transition (pour un changement rapide) ---
const TRANSITION_SPEED: float = 0.2 # Durée en secondes pour la transition

# Fonction principale pour basculer
func toggle_day_night():
	is_day = !is_day
	
	# Définir les cibles de l'animation
	var target_sun_color: Color
	var target_sun_energy: float
	var target_ambient_energy: float
	var target_rotation: Vector3
	
	if is_day:
		target_sun_color = SUN_COLOR_DAY
		target_sun_energy = SUN_ENERGY_DAY
		target_ambient_energy = AMBIENT_ENERGY_DAY
		target_rotation = Vector3(deg_to_rad(45), deg_to_rad(45), 0) # Position Jour
	else:
		target_sun_color = SUN_COLOR_NIGHT
		target_sun_energy = SUN_ENERGY_NIGHT
		target_ambient_energy = AMBIENT_ENERGY_NIGHT
		target_rotation = Vector3(deg_to_rad(225), deg_to_rad(45), 0) # Position Nuit (soleil sous la terre)

	# Lancement des animations de transition (Tween)
	
	# 1. Lumière Solaire (Couleur et Intensité)
	var tween_light = create_tween()
	tween_light.set_parallel(true)
	tween_light.tween_property(sun_light, "light_color", target_sun_color, TRANSITION_SPEED)
	tween_light.tween_property(sun_light, "light_energy", target_sun_energy, TRANSITION_SPEED)
	
	# 2. Rotation du Soleil (pour changer l'ombre)
	var tween_rotation = create_tween()
	tween_rotation.tween_property(sun_light, "rotation", target_rotation, TRANSITION_SPEED)

	# 3. Lumière Ambiante (Environnement)
	var tween_ambient = create_tween()
	tween_ambient.tween_property(environment_resource, "ambient_light_energy", target_ambient_energy, TRANSITION_SPEED)

# Exemple de connexion : Appelez cette fonction quand le bouton est cliqué.
# func _on_button_pressed():
#     toggle_day_night()
