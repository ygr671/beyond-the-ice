extends Node3D


# Références aux nœuds :
# Les chemins sont simples car les nœuds sont des enfants directs de Main_scene
@onready var sun_light = $DirectionalLight3D 
@onready var world_environment = $WorldEnvironment

# Déclare la variable de ressource, initialisée dans _ready
var environment_resource: Environment = null

# --- Variables d'États et Constantes ---
var is_day: bool = true

# Variables de Jour
const SUN_COLOR_DAY := Color(1.0, 0.9, 0.8) # Blanc/Jaune
const SUN_ENERGY_DAY: float = 2.0
const AMBIENT_ENERGY_DAY: float = 1.0
const SUN_ROTATION_DAY := Vector3(deg_to_rad(0), deg_to_rad(0), 0)

# Variables de Nuit
const SUN_COLOR_NIGHT := Color(0.1, 0.1, 0.2) # Bleu foncé
const SUN_ENERGY_NIGHT: float = 0.05
const AMBIENT_ENERGY_NIGHT: float = 0.05
const SUN_ROTATION_NIGHT := Vector3(deg_to_rad(-229.6), deg_to_rad(0), 0)
 
# Paramètres de Transition (rapide)
const TRANSITION_SPEED: float = 1.5

# --- Initialisation Sécurisée ---
func _ready():
	# 1. Vérifie si WorldEnvironment existe
	if world_environment:
		# 2. Vérifie si une ressource Environment est déjà attachée
		if world_environment.environment == null:
			# Si non, la crée pour éviter l'erreur de 'null instance'
			world_environment.environment = Environment.new()
			print("INFO: Nouvelle ressource Environment créée pour WorldEnvironment.")
			
		# 3. Récupère la référence à la ressource une fois qu'elle est garantie d'exister
		environment_resource = world_environment.environment
		
	else:
		print("ERREUR: Le nœud WorldEnvironment est introuvable. Système Jour/Nuit non fonctionnel.")


# --- Fonction Principale de Bascule ---
func toggle_day_night():
	# Ne rien faire si les nœuds cruciaux ne sont pas chargés
	if !sun_light or !environment_resource:
		print("Avertissement: Les références de lumière/environnement sont manquantes.")
		return
		
	is_day = !is_day
	
	# Définition des cibles
	var target_sun_color: Color
	var target_sun_energy: float
	var target_ambient_energy: float
	var target_rotation: Vector3
	
	if is_day:
		target_sun_color = SUN_COLOR_DAY
		target_sun_energy = SUN_ENERGY_DAY
		target_ambient_energy = AMBIENT_ENERGY_DAY
		target_rotation = SUN_ROTATION_DAY
	else:
		target_sun_color = SUN_COLOR_NIGHT
		target_sun_energy = SUN_ENERGY_NIGHT
		target_ambient_energy = AMBIENT_ENERGY_NIGHT
		target_rotation = SUN_ROTATION_NIGHT

	# Lancement des animations (Tween)
	
	# 1. Lumière Solaire (Couleur et Intensité)
	var tween_light = create_tween()
	tween_light.set_parallel(true)
	tween_light.tween_property(sun_light, "light_color", target_sun_color, TRANSITION_SPEED)
	tween_light.tween_property(sun_light, "light_energy", target_sun_energy, TRANSITION_SPEED)
	
	# 2. Rotation du Soleil/Lune
	tween_light.tween_property(sun_light, "rotation", target_rotation, TRANSITION_SPEED)

	# 3. Lumière Ambiante (Environnement)
	var tween_ambient = create_tween()
	tween_ambient.tween_property(environment_resource, "ambient_light_energy", target_ambient_energy, TRANSITION_SPEED)

# Fonction à connecter au signal 'pressed' de votre bouton UI
func _on_day_night_button_pressed():
	toggle_day_night()
