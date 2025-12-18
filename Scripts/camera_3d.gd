extends Camera3D
## @class_doc
## @description Gestionnaire d'interaction de la camera.
## Ce script est attache a la Camera3D et gere la logique de raycasting
## pour detecter les PNJ survolees par la souris.
## Il utilise un timer pour maintenir le statut de survol pendant une courte duree.
## @tags camera, interaction, raycasting


## @var_doc
var mouse_position = Vector2()

# On récupère le nœud qui contient main_scene.gd (ajuste le chemin selon ton arborescence)
@onready var main_node = get_tree().root.get_child(0) 

# On récupère le nœud physique de Knuckles (Area3D ou StaticBody3D)
@onready var knuckles = $"../../Ugandan_Knuckles"

var tutorial_finished : bool = true

# Dans Camera3D.gd

func _input(event):
	if tutorial_finished and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_mouse_over_knuckles_no_collision():
			print("Knuckles cliqué (via détection 2D) !")
			
			# On cherche le script principal de manière plus robuste
			var main_script = get_tree().current_scene 
			
			if main_script.has_method("trigger_random_knuckles_reaction"):
				main_script.trigger_random_knuckles_reaction()
			else:
				print("ERREUR : La fonction n'est pas trouvée dans ", main_script.name)
# Dans Camera3D.gd

func is_mouse_over_knuckles_no_collision() -> bool:
	# 1. On récupère la position 3D de Knuckles
	var knuckles_pos_3d = knuckles.global_position
	
	# 2. On vérifie si Knuckles est devant la caméra (pas derrière)
	if is_position_behind(knuckles_pos_3d):
		return false
		
	# 3. On projette cette position 3D sur l'écran 2D (en pixels)
	var screen_pos = unproject_position(knuckles_pos_3d)
	
	# 4. On calcule la distance entre la souris et ce point projeté
	var mouse_pos = get_viewport().get_mouse_position()
	var distance = mouse_pos.distance_to(screen_pos)
	
	# 5. Si la souris est à moins de 50 pixels du centre de Knuckles, on valide
	# Ajuste le chiffre '50' selon la taille de Knuckles à l'écran
	return distance < 60.0
	
## @var_doc
## @description Reference au PNJ actuellement survole. Null si aucun PNJ n'est survole.
## @tags state, npc
var current_hovered_npc: NavigationNPC = null

## @var_doc
## @description Compteur decroissant utilise pour maintenir le statut de survol actif.
## @tags timer
var hover_timer: float = 0.0

## @const_doc
## @description Duree (en secondes) pendant laquelle le survol doit rester actif
## avant de s'effacer, meme si la souris arrete de bouger.
## @tags config, timer
const HOVER_DURATION: float = 3.0

## @func_doc
## @description Capture les evenements d'entree utilisateur.
## Met a jour la position de la souris et lance immediatement la verification de survol.
## @param event: InputEvent L'evenement d'entree recu.
## @return void


## @func_doc
## @description Traitement de la logique de jeu (par frame).
## Gere la degressivite du minuteur de survol (hover_timer) pour desactiver
## le survol si la souris reste immobile trop longtemps.
## @param delta: float Temps ecoule depuis la derniere frame.
## @return void
## @tags core, timer
func _process(delta: float) -> void:
	if current_hovered_npc and hover_timer > 0:
		hover_timer -= delta
		if hover_timer <= 0:
			current_hovered_npc = null

## @func_doc
## @description Effectue un raycast a partir de la position de la souris dans le monde 3D
## pour detecter si un PNJ est touche.
## Met a jour 'current_hovered_npc' et reinitialise 'hover_timer' si un PNJ est trouve.
## @tags raycasting, interaction, physics
func check_npc_hover():
	var space_state = get_world_3d().direct_space_state
	
	# 1. Calcul de l'origine du rayon (position de la camera)
	var ray_origin = project_ray_origin(mouse_position)
	# 2. Calcul de la fin du rayon a 1000 unites de distance
	var ray_end = ray_origin + project_ray_normal(mouse_position) * 1000.0
	
	# Creation de la requete de raycast
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)

	# Verification du resultat
	if result and result.collider is NavigationNPC:
		var npc = result.collider as NavigationNPC
		
		# Si un nouveau PNJ est survole, ou si le meme PNJ est toujours survole
		if current_hovered_npc != npc:
			current_hovered_npc = npc
			# PLACEZ LA FONCTION ICI
			# function_to_call_on_hover(npc)
			hover_timer = HOVER_DURATION
		else:
			# Reinitialise le timer pour maintenir le survol si la souris bouge sur le PNJ
			hover_timer = HOVER_DURATION
	
	# Note: Si le raycast ne touche rien ou touche un objet qui n'est pas un NavigationNPC,
	# le 'current_hovered_npc' sera mis a null dans _process lorsque le timer expire.
