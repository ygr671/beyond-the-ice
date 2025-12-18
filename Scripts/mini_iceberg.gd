## @class_doc
## @description Controleur pour les petits icebergs (mini icebergs).
## Gere les transitions de couleur du materiau via un systeme de Tween.
## @tags environment, visual, effects, mini_iceberg
extends Node3D

class_name Mini_iceberg_controller
## @const_doc
## @description Vitesse de transition pour le changement de couleur.
## @tags config, animation
const TRANSITION_SPEED: float = 1.5

## @onready_doc
## @description Reference au materiau BaseMaterial3D de l'iceberg.
## @tags nodes, materials
@onready var iceberg_material: BaseMaterial3D

## @func_doc
## @description Initialisation du script.
## Recupere le materiau depuis le MeshInstance3D cible dans la hierarchie.
## @tags init
func _ready():
	# Récupère le matériau du mesh
	var iceberg_mesh = $Sketchfab_model/Root/Cylinder/Cylinder_0 as MeshInstance3D

	if iceberg_mesh:
		# Prend le matériau override ou celui du mesh
		iceberg_material = iceberg_mesh.get_surface_override_material(0)
		if iceberg_material == null and iceberg_mesh.mesh:
			iceberg_material = iceberg_mesh.mesh.surface_get_material(0)
	

## @func_doc
## @description Change la couleur de l'iceberg de maniere fluide.
## @param new_color: Color La nouvelle couleur cible a appliquer.
## @tags animation, color
func set_mini_iceberg_color(new_color: Color):
	if iceberg_material == null:
		return
	
	var current_color = iceberg_material.albedo_color
	
	if current_color == new_color:
		return
	
	# Crée un tween pour transition fluide
	var tween = create_tween()
	tween.tween_method(
		Callable(self, "_update_mini_iceberg_color"),
		current_color,
		new_color,
		TRANSITION_SPEED
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
# Fonction appelée pendant le tween
## @func_doc
## @description Met a jour l'albedo du materiau pendant l'animation.
## @param color: Color Couleur intermedaire envoyee par le Tween.
## @tags internal, animation
func _update_mini_iceberg_color(color: Color):
	if iceberg_material:
		iceberg_material.albedo_color = color
