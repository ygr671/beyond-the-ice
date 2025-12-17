## @class_doc
## @description Contrôleur d'animation pour un plan d'eau 3D utilisant un ShaderMaterial.
## Gère l'initialisation du matériau, le changement de couleur avec transition,
## et l'ajustement dynamique des paramètres du shader (e.g., "Amount" pour l'agitation/crépitement).
## @tags 3d, shader, animation, environment, low_poly

extends Node3D

## @class LowPolyWater
class_name low_poly_water

## @const_doc
## @description Vitesse de transition utilisee lors du changement de couleur de l'eau (en secondes).
## @tags config
const TRANSITION_SPEED: float = 1.5

## @const_doc
## @description Valeur par defaut pour le parametre 'Amount' du shader (agitation ou crépitement).
## @tags config, shader
const NORMAL_AMOUNT: float = 0.401 

## @onready_doc
## @description Reference au MeshInstance3D representant le plan d'eau.
## @tags nodes, 3d
@onready var water_mesh: MeshInstance3D = $MeshInstance3D

## @var_doc
## @description Le ShaderMaterial utilise pour controler l'apparence de l'eau.
## C'est une instance dupliquee pour eviter de modifier le materiel original.
## @type ShaderMaterial
## @tags state, material
var water_material: ShaderMaterial = null

## @func_doc
## @description Initialisation. Prepare le ShaderMaterial et definit la valeur initiale 'Amount'.
## @tags init, core
func _ready():
	water_material = get_water_shader_material()

	if water_material == null:
		print("ERREUR LowPolyWater : Le ShaderMaterial n'a pas pu être préparé pour l'animation.")
	else:
		print("SUCCÈS LowPolyWater : ShaderMaterial prêt à être utilisé.")
		
		# Définit le paramètre par défaut du shader
		water_material.set_shader_parameter("Amount", NORMAL_AMOUNT) 

## @func_doc
## @description Recherche et prepare le ShaderMaterial a partir du MeshInstance3D.
## Il s'assure de dupliquer le material trouve pour permettre des modifications uniques
## sans affecter d'autres maillages qui pourraient le partager.
## @return ShaderMaterial Le material duplique et prepare, ou null en cas d'erreur.
## @tags utility, material
func get_water_shader_material() -> ShaderMaterial:
	
	if water_mesh == null:
		print("ERREUR : MeshInstance3D enfant non trouvé ! Vérifiez le nom '$MeshInstance3D'")
		return null
		
	var material: Material = null
	
	# 1. Tente d'obtenir le material override
	material = water_mesh.get_surface_override_material(0)
	
	# 2. Si pas d'override, tente d'obtenir le material de la Mesh
	if material == null and water_mesh.mesh != null:
		material = water_mesh.mesh.surface_get_material(0)
		
	if material is ShaderMaterial:
		# Duplication et application du ShaderMaterial
		var duplicated_material = material.duplicate() as ShaderMaterial
		water_mesh.set_surface_override_material(0, duplicated_material)
		return duplicated_material
	else:
		# Gestion des erreurs si le material n'est pas un ShaderMaterial ou est manquant
		if material != null:
			print("ERREUR LowPolyWater : Matériau trouvé ({material.get_class()}) n'est pas un ShaderMaterial.")
		else:
			print("ERREUR LowPolyWater : Aucun matériau trouvé à l'index 0 du maillage.")
		return null
		
## @func_doc
## @description Anime le paramètre 'Amount' du shader (agitation/crépitement).
## L'ancienne animation (Tween) est tuee avant d'appliquer la nouvelle valeur.
## NOTE: Le Tween est désactivé et le paramètre est appliqué directement dans le code fourni.
## @param target_amount: float La valeur cible pour le paramètre 'Amount'.
## @param duration: float Duree de l'animation (non utilisee dans le code actuel).
## @return void
## @tags animation, shader
func animate_crackle_amount(target_amount: float, _duration: float):
	
	if water_material == null:
		print("ERREUR CRÉPITEMENT : water_material est null, impossible d'animer.")
		return
	print("Crépitement")

	# Application directe du paramètre (sans animation Tween)
	water_material.set_shader_parameter("amount", target_amount)
	
	# Tentative de suppression d'un ancien Tween (logique de sécurité)
	if water_material.has_meta("crackle_tween") and is_instance_valid(water_material.get_meta("crackle_tween")):
		water_material.get_meta("crackle_tween").kill()


## @func_doc
## @description Fonction de rappel utilisee par le Tween pour mettre à jour la couleur du shader.
## @param color: Color La couleur a appliquer au parametre "out_col" du shader.
## @return void
## @tags utility, shader, tween
func _update_shader_color(color: Color):
	if water_material:
		water_material.set_shader_parameter("out_col", color) 
		
## @func_doc
## @description Anime la couleur de l'eau vers une nouvelle couleur cible.
## Utilise un Tween.tween_method pour une transition de couleur fluide.
## @param new_color: Color La nouvelle couleur cible pour l'eau.
## @return void
## @tags animation, shader
func set_water_color_target(new_color: Color):
	if water_material == null:
		print("ERREUR : Impossible de changer la couleur, water_material est null")
		return
		
	var current_color = water_material.get_shader_parameter("out_col")
	
	# Initialisation de la couleur si elle n'est pas encore definie
	if current_color == null:
		current_color = Color(0.2, 0.5, 0.8, 1.0) 
		water_material.set_shader_parameter("out_col", current_color)
	
	# Evite de relancer l'animation si la couleur cible est deja atteinte
	if current_color == new_color:
		return
		
	var tween_color = create_tween()
	
	# Lance l'animation de couleur
	tween_color.tween_method(
		Callable(self, "_update_shader_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
