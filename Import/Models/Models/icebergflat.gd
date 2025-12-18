## @class_doc
## @description Controleur de l'iceberg principal utilisant des Shaders.
## Gere la recuperation robuste du materiau et les transitions de couleur via ShaderParameter.
## @tags environment, visual, shader, effects
extends Node3D

class_name Iceberg_controller

## @const_doc
## @description Vitesse de transition pour le changement de couleur du shader.
## @tags config, animation
const TRANSITION_SPEED: float = 1.5

## @onready_doc
## @description Reference directe au MeshInstance3D de l'iceberg.
## @tags nodes, mesh
@onready var iceberg_mesh: MeshInstance3D = $Iceberg_Iceberg_0

## @var_doc
## @description Reference au ShaderMaterial duplique pour les modifications de couleur.
## @tags material, shader
var iceberg_material: ShaderMaterial = null

## @func_doc
## @description Initialisation du script. Recupere et duplique le materiau au demarrage.
## @tags init
func _ready():
	# 2. Appel de la fonction de recuperation robuste
	iceberg_material = get_iceberg_material()

## @func_doc
## @description Recupere le materiau de maniere robuste (Override ou Mesh ressource).
## Duplique le materiau s'il s'agit d'un ShaderMaterial pour isoler l'instance.
## @return ShaderMaterial Le materiau recupere et duplique, ou null.
## @tags logic, material, shader
func get_iceberg_material() -> ShaderMaterial:
	if iceberg_mesh == null:
		print("ERREUR Iceberg : Le noeud enfant '$Iceberg_Iceberg_0' n'est pas trouve.")
		return null
	
	var material: Material = null
	
	# 1. Tente de recuperer l'Override de surface (methode preferee)
	material = iceberg_mesh.get_surface_override_material(0)
	
	if material == null and iceberg_mesh.mesh != null:
		# 2. Si l'Override est null, tente de recuperer le materiau directement du Mesh
		material = iceberg_mesh.mesh.surface_get_material(0)
	
	if material is ShaderMaterial:
		# 3. Dupliquer pour garantir que l'animation n'affecte pas d'autres instances
		var duplicated_material = material.duplicate() as ShaderMaterial
		
		# 4. Appliquer le materiau duplique comme override
		iceberg_mesh.set_surface_override_material(0, duplicated_material)
			
		return duplicated_material
	else:
		return null

## @func_doc
## @description Lance une transition fluide vers une nouvelle couleur de shader.
## @param new_color: Color La couleur cible pour le parametre 'albedo_color'.
## @tags animation, shader, color
func set_iceberg_color_target(new_color: Color):
	if iceberg_material == null:
		return
	
	var tween_color = create_tween()
	
	tween_color.tween_method(
		Callable(self, "_update_shader_color"),           
		iceberg_material.get_shader_parameter("albedo_color"), 
		new_color,                                        
		TRANSITION_SPEED                                  
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## @func_doc
## @description Met a jour le parametre 'albedo_color' du shader pendant le tween.
## @param color: Color La couleur intermediaire calculee par le tween.
## @tags internal, shader, animation
func _update_shader_color(color: Color):
	if iceberg_material:
		iceberg_material.set_shader_parameter("albedo_color", color)
