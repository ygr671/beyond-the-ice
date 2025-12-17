extends Node3D

class_name Iceberg_controller

const TRANSITION_SPEED: float = 1.5

# Référence au matériau de l'iceberg
@onready var iceberg_material: BaseMaterial3D

func _ready():
	# Récupère le matériau du mesh
	var iceberg_mesh = $Iceberg_Iceberg_0 as MeshInstance3D
	
	if iceberg_mesh:
		# Prend le matériau override ou celui du mesh
		iceberg_material = iceberg_mesh.get_surface_override_material(0)
		if iceberg_material == null and iceberg_mesh.mesh:
			iceberg_material = iceberg_mesh.mesh.surface_get_material(0)
		
		if iceberg_material:
			print("✓ Matériau iceberg chargé")
		else:
			print("✗ Aucun matériau trouvé sur l'iceberg")

# Fonction publique pour changer la couleur
func set_iceberg_color(new_color: Color):
	if iceberg_material == null:
		print("ERREUR: Matériau iceberg non disponible")
		return
	
	var current_color = iceberg_material.albedo_color
	
	if current_color == new_color:
		return
	
	# Crée un tween pour transition fluide
	var tween = create_tween()
	tween.tween_method(
		Callable(self, "_update_iceberg_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Fonction appelée pendant le tween
func _update_iceberg_color(color: Color):
	if iceberg_material:
		iceberg_material.albedo_color = color
