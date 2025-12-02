extends Node3D

class_name LowPolyWater

const TRANSITION_SPEED: float = 1.5

# CORRECTION : Trouvez le MeshInstance3D
@onready var water_mesh = $MeshInstance3D 

# Référence au ShaderMaterial
@onready var water_material: ShaderMaterial

func _ready():
	# Vérification du mesh
	if water_mesh == null:
		print("ERREUR : MeshInstance3D non trouvé !")
		print("Assurez-vous qu'il y a un enfant nommé 'MeshInstance3D'")
		return
	
	# DEBUG : Afficher les informations
	print("=== DEBUG LowPolyWater ===")
	print("Mesh trouvé : ", water_mesh.name)
	print("Mesh resource : ", water_mesh.mesh)
	
	# 1. ESSAYER D'ABORD LES OVERRIDES (ce que vous voulez normalement)
	water_material = water_mesh.get_surface_override_material(0)
	
	if water_material != null:
		print("✓ Matériau trouvé via get_surface_override_material(0)")
		print("  Type : ", water_material.get_class())
	else:
		print("✗ Aucun matériau override trouvé")
		
		# 2. Regarder si le mesh a un matériau intégré
		if water_mesh.mesh:
			var mesh_material = water_mesh.mesh.surface_get_material(0)
			if mesh_material:
				print("⚠ Matériau trouvé dans le mesh (via surface_get_material)")
				print("  Type : ", mesh_material.get_class())
				print("  ATTENTION : Ce matériau est partagé entre toutes les instances !")
				
				# Créer un override pour éviter de modifier la ressource partagée
				water_material = mesh_material.duplicate() as ShaderMaterial
				water_mesh.set_surface_override_material(0, water_material)
				print("  ✓ Override créé en dupliquant le matériau")
			else:
				print("✗ Aucun matériau dans le mesh non plus")
		else:
			print("✗ Le MeshInstance3D n'a pas de mesh assigné !")
	
	# Vérification finale
	if water_material == null:
		print("ERREUR : Aucun ShaderMaterial trouvé !")
		print("\nSOLUTIONS :")
		print("1. Sélectionnez le MeshInstance3D dans l'éditeur")
		print("2. Dans l'inspecteur, allez dans 'Surface Material Override'")
		print("3. Cliquez sur '[empty]' et créez un 'New ShaderMaterial'")
		print("4. Dans ce ShaderMaterial, assignez votre shader d'eau")
	else:
		print("✓ SUCCÈS : ShaderMaterial prêt à être utilisé")
		print("  Chemin : ", water_material.resource_path if water_material.resource_path else "(pas sauvegardé)")

# --- Logique de Changement de Couleur ---

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

func _update_shader_color(color: Color):
	if water_material:
		water_material.set_shader_parameter("out_col", color)
