## @class_doc
## @description Gere l'apparence visuelle et les transitions de couleur de l'iceberg.
## Permet des changements de couleur fluides via des Tweens sur le materiau Albedo.
## @tags environment, visual, effects
extends Node3D


class_name Iceberg
## @const_doc
## @description Vitesse de transition lors du changement de couleur (en secondes).
## @tags config, animation
const TRANSITION_SPEED: float = 1.5

## @onready_doc
## @description Reference au materiau de l'iceberg pour modifier ses proprietes.
## @tags nodes, materials
@onready var iceberg_material: BaseMaterial3D

## @func_doc
## @description Initialise le script en recuperant le materiau du MeshInstance3D.
## Verifie d'abord l'override de surface avant de recuperer le materiau du mesh lui-meme.
## @tags init
func _ready():
	# Récupère le matériau du mesh
	var iceberg_mesh = $Iceberg_Iceberg_0 as MeshInstance3D
	
	if iceberg_mesh:
		# Prend le matériau override ou celui du mesh
		iceberg_material = iceberg_mesh.get_surface_override_material(0)
		if iceberg_material == null and iceberg_mesh.mesh:
			iceberg_material = iceberg_mesh.mesh.surface_get_material(0)

## @func_doc
## @description Lance une transition fluide vers une nouvelle couleur.
## Utilise un Tween pour interpoler entre la couleur actuelle et la nouvelle cible.
## @param new_color: Color La couleur cible a appliquer.
## @tags animation, visual
func set_iceberg_color(new_color: Color):
	if iceberg_material == null:
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

## @func_doc
## @description Met a jour la couleur Albedo du materiau (appelee par le Tween).
## @param color: Color La couleur intermediaire calculee par le Tween.
## @tags internal, animation
func _update_iceberg_color(color: Color):
	if iceberg_material:
		iceberg_material.albedo_color = color
