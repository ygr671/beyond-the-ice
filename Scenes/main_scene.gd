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

## @var_doc
## @description Indique si le tutoriel est termine.
## @tags state, progression
var tutorial_finished : bool = false

## @onready_doc
## @description References aux differents elements de l'interface du tutoriel et de la scene.
## @tags nodes, ui
@onready var t1 = $Salles/salon/ui_Salon/Tutorial1
@onready var t2 = $Salles/salon/ui_Salon/Tutorial2
@onready var t3 = $Salles/salon/ui_Salon/Tutorial3
@onready var t4 = $Salles/salon/ui_Salon/Tutorial4
@onready var GL = $Salles/salon/ui_Salon/GL
@onready var KTE = $Salles/salon/ui_Salon/KTE_textbox
@onready var salle = $Salles/salon/Salle


## @onready_doc
## @description Reference au nœud WorldEnvironment qui controle l'eclairage ambiant et le ciel.
## @tags nodes, environment
@onready var worldenv = $WorldEnvironment

## @onready_doc
## @description Reference au contrôleur de l'iceberg (script Iceberg_controller.gd).
## @type Iceberg
## @tags nodes, environment
@onready var iceberg_node = $Iceberg as Iceberg

## @onready_doc
## @description Reference au controleur des mini icebergs.
## @tags nodes, environment
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

@onready var soundkt = $KTE_sound

## @func_doc
## @description Initialisation de la scene: masque l'UI et lance le tutoriel.
## Met egalement a jour les couleurs initiales de l'eau et de l'iceberg.
## @tags init, core
func _ready():
	t1.hide()
	t2.hide()
	t3.hide()
	t4.hide()
	GL.hide()
	KTE.hide()
	salle.hide()
	run_full_tutorial()
	
	
	# Initialisation de la couleur de l'eau au Jour
	if water_node and water_node.has_method("set_water_color_target"):
		water_node.set_water_color_target(WATER_COLOR_DAY)
	else:
		print("ERREUR CRITIQUE: Le nœud d'eau ($LowPolyWater) est trouvé, mais le script Low_poly_water.gd est manquant ou n'a pas la fonction 'set_water_color_target'.")
		
	# Initialisation de la couleur de l'iceberg au Jour
	if iceberg_node and iceberg_node.has_method("set_iceberg_color_target"):
		iceberg_node.set_iceberg_color_target(ICEBERG_COLOR_DAY)

## @func_doc
## @description Execute la sequence complete du tutoriel.
## Deplace le personnage a travers differentes etapes et affiche les messages d'aide.
## @tags tutorial, logic
func run_full_tutorial():
	# Étape 0 : Position de base + Saut
	await move_knuckles_to_step(0)
	var jump_tween = create_tween().set_loops()
	var base_y = knuckles.global_position.y
	jump_tween.tween_property(knuckles, "global_position:y", base_y + 1.2, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(knuckles, "global_position:y", base_y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	

	KTE.show()
	await get_tree().create_timer(4.0).timeout 
	KTE.hide()
	jump_tween.kill()
	
	# Étape 1 : Les Salles
	await move_knuckles_to_step(1)
	
	t1.show()
	await wait_for_click()
	t1.hide()
	
	# Étape 2 : Satisfaction Globale
	await move_knuckles_to_step(2)
	
	t2.show()
	await wait_for_click()
	t2.hide()
	
	# Étape 3 : Les 3 Boutons
	await move_knuckles_to_step(3)
	
	t3.show()
	await wait_for_click()
	t3.hide()
	
	# Étape 4 : Fin de Mission
	await move_knuckles_to_step(4)
	
	t4.show()
	await wait_for_click()
	t4.hide()
	
	# Étape 5 : Knuckles Géant
	await move_knuckles_to_step(5)
	knuckles.scale = Vector3(20, 20, 20) 
	
	# Étape 6 : Conclusion
	await move_knuckles_to_step(6)

	GL.show()
	await wait_for_click()
	GL.hide()
	salle.show()
	
	# Reset
	knuckles.scale = Vector3(0.5, 0.5, 0.5) 
	await move_knuckles_to_step(0)
	tutorial_finished = true

## @var_doc
## @description Definition des etapes du tutoriel (Positions et Rotations).
## @tags tutorial, data
var tutorial_steps = [
	{"pos": Vector3(-27.287, -17.151, -49.14), "rot": 37.3},  # Base
	{"pos": Vector3(-35.7, -17.151, -24.943),   "rot": -57.0}, # T1
	{"pos": Vector3(-24.657, -17.151, -20.053), "rot": 76.5},  # T2
	{"pos": Vector3(-40.167, -17.151, -36.674), "rot": 168.1}, # T3
	{"pos": Vector3(-13.883, -17.151, -27.847), "rot": 161.6}, # T4
	{"pos": Vector3(0.098, -17.151, -46.531),   "rot": 161.6}, # T5
	{"pos": Vector3(12.947, -56.702, 9.904),    "rotx": -19.9, "roty": 46.9, "rotz": 1.1} # T6
]

## @onready_doc
## @description Reference au noeud du personnage Knuckles.
## @tags nodes, npc
@onready var knuckles = $Ugandan_Knuckles # Ajuste le chemin vers ton nœud Knuckles
## @func_doc
## @description Deplace Knuckles vers une etape specifique du tutoriel avec une transition fluide.
## @param step_index: int L'index de l'etape dans tutorial_steps.
## @tags tutorial, animation, movement
func move_knuckles_to_step(step_index: int):
	if step_index >= tutorial_steps.size():
		return

	var target = tutorial_steps[step_index]
	var tween = create_tween().set_parallel(true)
	
	# 1. Déplacement vers la position cible
	tween.tween_property(knuckles, "global_position", target["pos"], 1.5).set_trans(Tween.TRANS_SINE)
	
	# 2. Gestion des rotations (conversion degrés -> radians)
	# On récupère les valeurs ou 0.0 si elles n'existent pas dans le dictionnaire
	var rx = deg_to_rad(target.get("rotx", 0.0))
	var ry = deg_to_rad(target.get("rot", target.get("roty", 0.0))) # Supporte "rot" ou "roty"
	var rz = deg_to_rad(target.get("rotz", 0.0))
	
	tween.tween_property(knuckles, "global_rotation", Vector3(rx, ry, rz), 1.2)
	
	await tween.finished

## @func_doc
## @description Fait sautiller Knuckles sur place.
## @param duration: float Duree d'un saut complet.
## @param height: float Hauteur du saut.
## @tags tutorial, animation
func hop_knuckles(duration: float = 0.5, height: float = 1.5):
	# On crée un tween qui va faire monter puis descendre Knuckles
	var tween = create_tween().set_loops() # set_loops() fait que ça se répète à l'infini
	
	# Calcul de la position haute
	var start_pos = knuckles.global_position
	var up_pos = start_pos + Vector3(0, height, 0)
	
	# Animation : Monte (TRANS_QUAD pour un effet de saut naturel)
	tween.tween_property(knuckles, "global_position:y", up_pos.y, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Animation : Redescend
	tween.tween_property(knuckles, "global_position:y", start_pos.y, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

## @func_doc
## @description Met le script en pause jusqu'a ce qu'un clic gauche de la souris soit detecte.
## @tags tutorial, input
func wait_for_click():
	while true:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# On attend un tout petit peu que le bouton soit relâché pour éviter de sauter 2 étapes
			await get_tree().create_timer(0.2).timeout
			return
		await get_tree().process_frame # Attend l'image suivante pour ne pas bloquer le jeu
	
	
## @var_doc
## @description Gestionnaire de temps pour les reactions du personnage.
## @tags internal
var reaction_timer: SceneTreeTimer

## @func_doc
## @description Declenche une reaction aleatoire (texte et saut) lorsque Knuckles est touche.
## @tags interaction, npc, dialog
func trigger_random_knuckles_reaction():
	print("Touché")
	soundkt.play()
	
	# 1. Mise à jour du texte (écrase le précédent immédiatement)
	var label_node = $Salles/salon/ui_Salon/KTE_textbox/Label
	if label_node:
		label_node.text = knuckles.dialog_lines.pick_random()
		$Salles/salon/ui_Salon/KTE_textbox.show()
	
	# 2. Animation de saut (Annule le tween précédent s'il existe pour éviter les bugs de hauteur)
	var jump_height = 1.5
	var duration = 0.4
	var base_y = knuckles.global_position.y # Attention: assure-toi que base_y est la position AU SOL
	
	var tween = create_tween()
	tween.tween_property(knuckles, "global_position:y", base_y + jump_height, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(knuckles, "global_position:y", base_y, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 3. Gestion du temps (Reset du chrono de 3 secondes)
	# On crée un identifiant unique pour ce clic
	var current_click_time = Time.get_ticks_msec()
	self.set_meta("last_click", current_click_time)
	
	await get_tree().create_timer(3.0).timeout
	
	# On ne cache que si aucun autre clic n'a eu lieu depuis (Vérification du chrono)
	if self.get_meta("last_click") == current_click_time:
		$Salles/salon/ui_Salon/KTE_textbox.hide()






## @func_doc
## @description Bascule l'etat entre Jour et Nuit.
## Orchestre les changements de couleur de l'eau, de l'iceberg et de l'energie environnementale.
## @return void
## @tags time, environment, animation
func toggle_day_night():
	player_controller.is_day = !player_controller.is_day
	
	var target_iceberg_color: Color
	var target_water_color: Color
	
	if player_controller.is_day:
		target_iceberg_color = ICEBERG_COLOR_DAY      # #a4cfd5
		target_water_color = WATER_COLOR_DAY
	else:
		target_iceberg_color = ICEBERG_COLOR_NIGHT    # #060f11
		target_water_color = WATER_COLOR_NIGHT
	
	# 1. Transition iceberg - CORRECTION ICI
	if iceberg_node:
		iceberg_node.set_iceberg_color(target_iceberg_color)
		mini_iceberg.set_mini_iceberg_color(target_iceberg_color)
		
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
		
	else:
		# Beau temps (calme)
		water_node.animate_crackle_amount(0.4, 1.0) # Normalise l'agitation
		snow_node.speed_scale = 1 # Normalise la vitesse de la neige
