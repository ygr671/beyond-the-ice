extends Node3D

class_name Low_poly_water

const TRANSITION_SPEED: float = 1.5
const NORMAL_AMOUNT: float = 0.401 # Valeur de crépitement de base

@onready var water_mesh: MeshInstance3D = $MeshInstance3D
# Assurez-vous que le MeshInstance3D est l'enfant nommé "MeshInstance3D"
var water_material: ShaderMaterial = null

func _ready():
	water_material = get_water_shader_material()

	if water_material == null:
		print("ERREUR LowPolyWater : Le ShaderMaterial n'a pas pu être préparé pour l'animation.")
	else:
		print("SUCCÈS LowPolyWater : ShaderMaterial prêt à être utilisé.")
		# Initialiser l'uniforme de crépitement à sa valeur normale
		water_material.set_shader_parameter("Amount", NORMAL_AMOUNT) 


# Fonction révisée pour trouver, vérifier et préparer le ShaderMaterial
func get_water_shader_material() -> ShaderMaterial:
	# ... (Le corps de cette fonction reste inchangé : il trouve, duplique et retourne le matériau) ...
	if water_mesh == null:
		print("ERREUR : MeshInstance3D enfant non trouvé ! Vérifiez le nom '$MeshInstance3D'")
		return null
		
	var material: Material = null
	material = water_mesh.get_surface_override_material(0)
	
	if material == null and water_mesh.mesh != null:
		material = water_mesh.mesh.surface_get_material(0)
		
	if material is ShaderMaterial:
		var duplicated_material = material.duplicate() as ShaderMaterial
		water_mesh.set_surface_override_material(0, duplicated_material)
		return duplicated_material
	else:
		if material != null:
			print("ERREUR LowPolyWater : Matériau trouvé ({material.get_class()}) n'est pas un ShaderMaterial.")
		else:
			print("ERREUR LowPolyWater : Aucun matériau trouvé à l'index 0 du maillage.")
		return null
		

func animate_crackle_amount(target_amount: float, duration: float):
	
	if water_material == null:
		print("ERREUR CRÉPITEMENT : water_material est null, impossible d'animer.")
		return
	print("Crépitement")
		
	# 1. Définir la nouvelle valeur immédiatement.
	# On utilise le nom d'uniforme direct ("Amount") pour set_shader_parameter.
	water_material.set_shader_parameter("amount", target_amount)
	
	# 2. Arrêter tout Tween actif qui pourrait annuler ce changement (Nettoyage).
	if water_material.has_meta("crackle_tween") and is_instance_valid(water_material.get_meta("crackle_tween")):
		water_material.get_meta("crackle_tween").kill()
	# NOTE : Toute la logique de création de 'tween', 'tween.tween_property', 
	# et d'enregistrement du meta a été supprimée, car elle n'est plus nécessaire.
	# Le paramètre 'duration' n'est plus utilisé.

# -------------------------------------------------------------------------------------
# (Vos fonctions de couleur ci-dessous restent inchangées)
# -------------------------------------------------------------------------------------

func _update_shader_color(color: Color):
	if water_material:
		water_material.set_shader_parameter("out_col", color) 
		
func set_water_color_target(new_color: Color):
	if water_material == null:
		print("ERREUR : Impossible de changer la couleur, water_material est null")
		return
		
	var current_color = water_material.get_shader_parameter("out_col")
	
	if current_color == null:
		current_color = Color(0.2, 0.5, 0.8, 1.0) 
		water_material.set_shader_parameter("out_col", current_color)
	
	if current_color == new_color:
		return
		
	var tween_color = create_tween()
	
	tween_color.tween_method(
		Callable(self, "_update_shader_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
