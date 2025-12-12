## @class_doc
## @description Contrôleur d'animation pour un plan d'eau 3D basé sur un ShaderMaterial.
## Ce script gère le chargement sécurisé et la duplication du ShaderMaterial de l'eau
## pour assurer des modifications uniques de couleur. Il orchestre également la transition
## de couleur Jour/Nuit à l'aide de la fonction Tween.
## @tags 3d, shader, animation, environment, low_poly

extends Node3D

## @class Low_poly_water
class_name Low_poly_water

## @const_doc
## @description Vitesse de transition pour les animations (e.g., changement de couleur de l'eau).
## @tags config, animation
const TRANSITION_SPEED: float = 1.5

## @onready_doc
## @description Référence au nœud MeshInstance3D représentant le plan d'eau.
## @tags nodes, 3d
@onready var water_mesh = $MeshInstance3D 

## @onready_doc
## @description Référence au ShaderMaterial utilisé pour le rendu de l'eau.
## Ce matériau est soit un override, soit une ressource dupliquée.
## @type ShaderMaterial
## @tags state, material
@onready var water_material: ShaderMaterial

## @func_doc
## @description Initialisation. Charge de manière sécurisée le ShaderMaterial à partir du MeshInstance3D.
## La logique priorise le 'surface override' et duplique les matériaux intégrés du mesh
## pour éviter de modifier une ressource partagée.
## @tags init, core, material
func _ready():
	# Vérification et logs de debug omis ici pour la documentation finale
	
	if water_mesh == null:
		return
		
	# 1. ESSAYER D'ABORD LES OVERRIDES
	water_material = water_mesh.get_surface_override_material(0)
	
	if water_material == null:
		# 2. Regarder si le mesh a un matériau intégré
		if water_mesh.mesh:
			var mesh_material = water_mesh.mesh.surface_get_material(0)
			if mesh_material:
				# Créer un override en dupliquant le matériau partagé
				water_material = mesh_material.duplicate() as ShaderMaterial
				water_mesh.set_surface_override_material(0, water_material)
		
	# Vérification finale (logs de succès/échec omis pour la documentation)
	if water_material == null:
		# Afficher les solutions en cas d'erreur
		pass 

# --- Logique de Changement de Couleur ---

## @func_doc
## @description Anime la couleur de l'eau vers une nouvelle couleur cible.
## Utilise un Tween pour une transition fluide entre les couleurs.
## @param new_color: Color La nouvelle couleur cible pour le paramètre "out_col" du shader.
## @return void
## @tags animation, shader
func set_water_color_target(new_color: Color):
	if water_material == null:
		print("ERREUR : Impossible de changer la couleur, water_material est null")
		return
	
	# Récupérer la couleur actuelle du shader
	var current_color = water_material.get_shader_parameter("out_col")
	
	# Si le paramètre n'existe pas, utiliser une couleur par défaut
	if current_color == null:
		current_color = Color(0.2, 0.5, 0.8, 1.0) 
		water_material.set_shader_parameter("out_col", current_color)
	
	if current_color == new_color:
		return 
	
	# Créer la transition
	var tween_color = create_tween()
	
	tween_color.tween_method(
		Callable(self, "_update_shader_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## @func_doc
## @description Fonction de rappel utilisée par le Tween pour mettre à jour la couleur du shader.
## @param color: Color La couleur à appliquer au paramètre "out_col" du shader.
## @return void
## @tags utility, shader, tween
func _update_shader_color(color: Color):
	if water_material:
		water_material.set_shader_parameter("out_col", color)
