extends Node3D

class_name LowPolyWater

const TRANSITION_SPEED: float = 1.5


@onready var water_mesh = $MeshInstance3D 


@onready var water_material: ShaderMaterial

func _ready():

	if water_mesh == null:
		print("ERREUR : MeshInstance3D non trouvé !")
		print("Assurez-vous qu'il y a un enfant nommé 'MeshInstance3D'")
		return
	

	print("=== DEBUG LowPolyWater ===")
	print("Mesh trouvé : ", water_mesh.name)
	print("Mesh resource : ", water_mesh.mesh)
	

	water_material = water_mesh.get_surface_override_material(0)
	
	if water_material != null:
		print("Matériau trouvé via get_surface_override_material(0)")
		

		if water_mesh.mesh:
			var mesh_material = water_mesh.mesh.surface_get_material(0)
			if mesh_material:
				print("Matériau trouvé dans le mesh (via surface_get_material)")
				print("  Type : ", mesh_material.get_class())
				

				water_material = mesh_material.duplicate() as ShaderMaterial
				water_mesh.set_surface_override_material(0, water_material)
				
	

	if water_material == null:
		print("ERREUR : Aucun ShaderMaterial trouvé !")

	else:
		print("SUCCÈS : ShaderMaterial prêt à être utilisé")

func _update_shader_color(color: Color):
	if water_material:
		water_material.set_shader_parameter("out_col", color)
		
func set_water_color_target(new_color: Color):
	if water_material == null:
		print("ERREUR : Impossible de changer la couleur, water_material est null")
		return
	
	# Récupérer la couleur actuelle du shader
	var current_color = water_material.get_shader_parameter("out_col")
	
	# Si le paramètre n'existe pas, utiliser une couleur par défaut
	if current_color == null:
		current_color = Color(0.2, 0.5, 0.8, 1.0)  # Bleu eau par défaut
		water_material.set_shader_parameter("out_col", current_color)
	
	if current_color == new_color:
		return  # Même couleur, pas besoin de transition
	
	# Créer la transition
	var tween_color = create_tween()
	
	tween_color.tween_method(
		Callable(self, "_update_shader_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
