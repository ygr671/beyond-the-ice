# =========================================================
# Script Main_scene.gd
# =========================================================
extends Node3D

# CORRECTION 3 : Le typage fonctionne grâce à 'class_name Low_poly_water'
@onready var water_node = $LowPolyWater as Low_poly_water 

# --- Variables d'États et Constantes ---
var is_day: bool = true

# Couleurs cibles
const WATER_COLOR_DAY := Color(1.0, 1.0, 1.0)
const WATER_COLOR_NIGHT := Color(0.05, 0.1, 0.2) 


# --- Initialisation ---
func _ready():
	if water_node:
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
		# Ce message s'affichera uniquement si LowPolyWater n'est pas dans l'arborescence.
		print("ERREUR: Le nœud d'eau ($LowPolyWater) n'est pas trouvé ou mal typé.")


# --- Fonction Principale de Bascule (Jour/Nuit) ---
func toggle_day_night():
	if !water_node:
		return
		
	is_day = !is_day
	
	var target_water_color: Color
	
	if is_day:
		target_water_color = WATER_COLOR_DAY
	else:
		target_water_color = WATER_COLOR_NIGHT

	# Délègue la tâche d'animation au script de l'eau
	water_node.set_water_color_target(target_water_color)
	print("Couleur en train de changer")

# Fonction de connexion du Bouton UI (appelée par le script UI)
func _on_cycle_pressed():
	toggle_day_night()
