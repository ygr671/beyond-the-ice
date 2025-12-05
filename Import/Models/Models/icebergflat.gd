extends Node3D

class_name Iceberg_controller

const TRANSITION_SPEED: float = 1.5

# 1. UTILISATION EXCLUSIVE DE LA RÉFÉRENCE ONREADY (Enfant direct)
@onready var iceberg_mesh: MeshInstance3D = $Iceberg_Iceberg_0
var iceberg_material: ShaderMaterial = null

func _ready():
	# 2. Appel de la fonction de récupération robuste
	iceberg_material = get_iceberg_material()
	
	if iceberg_material == null:
		print("ERREUR Iceberg : Le ShaderMaterial n'a pas pu être préparé pour l'animation.")
		# Le script s'arrêtera silencieusement dans set_iceberg_color_target si le matériau est null.


# SUPPRESSION des fonctions find_iceberg_mesh() pour éviter les conflits et simplifier.
# La fonction de récupération est basée sur le MeshInstance3D référencé ci-dessus.
func get_iceberg_material() -> ShaderMaterial:
	if iceberg_mesh == null:
		print("ERREUR Iceberg : Le nœud enfant '$Iceberg_Iceberg_0' n'est pas trouvé.")
		return null
	
	var material: Material = null
	
	# --- LOGIQUE ROBUSTE DE RÉCUPÉRATION DU MATÉRIAU ---
	
	# 1. Tente de récupérer l'Override de surface (méthode préférée)
	material = iceberg_mesh.get_surface_override_material(0)
	
	if material == null and iceberg_mesh.mesh != null:
		# 2. Si l'Override est null, tente de récupérer le matériau directement de la ressource Mesh
		# C'est souvent le cas pour les maillages importés (.gltf)
		material = iceberg_mesh.mesh.surface_get_material(0)
	
	if material is ShaderMaterial:
		# 3. Dupliquer pour garantir que l'animation n'affecte pas d'autres instances
		var duplicated_material = material.duplicate() as ShaderMaterial
		
		# 4. Appliquer le matériau dupliqué comme override pour que le maillage l'utilise
		iceberg_mesh.set_surface_override_material(0, duplicated_material)
			
		return duplicated_material
	else:
		# Afficher le type de matériau trouvé, si un matériau existe.
		if material != null:
			print("ERREUR Iceberg : Matériau trouvé ({material.get_class()}) n'est pas un ShaderMaterial. Assurez-vous d'utiliser votre shader.")
		else:
			print("ERREUR Iceberg : Aucun matériau trouvé à l'index 0 du maillage.")
			
		return null


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

func _update_shader_color(color: Color):
	if iceberg_material:
		iceberg_material.set_shader_parameter("albedo_color", color)
