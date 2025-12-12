## @class_doc
## @description Classe de base pour la gestion du placement d'objets dans le monde 3D.
## Ce script est attache a un Node3D representant un meuble et gere la detection des collisions
## pour determiner si l'objet peut etre place (zone libre, surface supportee).
## @tags 3d, placement, collision, furniture, utility

extends Node3D

# --- References de Noeuds ---
## @onready_doc
## @description Tableau de RayCast3D utilises pour verifier la presence d'une surface sous l'objet.
## Les rayons sont nommes ray1 a ray4, et sont censes etre des enfants d'un noeud "Mesh".
## @tags nodes, raycast
@onready var raycasts = [$Mesh/ray1, $Mesh/ray2, $Mesh/ray3, $Mesh/ray4]

## @export_doc
## @description Tableau des MeshInstance3D constituant la geometrie de l'objet.
## Utilise pour changer dynamiquement le material (rouge/vert) lors du placement.
## @tags nodes, mesh
@export var meshes: Array[MeshInstance3D]

## @onready_doc
## @description Reference a l'Area3D utilisee pour detecter les chevauchements avec d'autres objets.
## @tags nodes, area
@onready var area = $Mesh/Area3D

## @onready_doc
## @description Material vert precharge pour indiquer un placement valide.
## @tags resources, material
@onready var green_mat = preload("res://materials/Object/green_placement.tres")

## @onready_doc
## @description Material rouge precharge pour indiquer un placement invalide.
## @tags resources, material
@onready var red_mat = preload("res://materials/Object/red_placement.tres")

## @var_doc
## @description Angle de rotation actuel de l'objet.
## @tags state, transform
var angle: float = 0

# --- Metadonnees pour l'inventaire/le jeu ---
## @export_doc
## @description Stock initial de cet objet dans l'inventaire.
## @tags metadata, inventory
@export var initial_stock: int = 1

## @export_doc
## @description Nombre d'unites ajoutees au stock lors d'une commande reussie.
## @tags metadata, inventory
@export var restock_count: int = 1

## @func_doc
## @description Initialisation. Nettoie et remplit le tableau 'meshes' de maniere recursive.
## @return void
## @tags init, setup, utility
func _ready() -> void:
	meshes.clear()
	for child in get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		elif child.get_child_count() > 0:
			# Recherche recursive pour les meshes enfants (meme dans d'autres noeuds)
			meshes += _get_meshes_recursive(child)

## @func_doc
## @description Recherche recursive de tous les CollisionShape3D dans l'arborescence d'un noeud donne.
## @param node: Node Noeud a partir duquel commencer la recherche.
## @return Array Liste des CollisionShape3D trouves.
## @tags utility, recursive
func _get_collisions_recursive(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is CollisionShape3D:
			result.append(child)
		if child.get_child_count() > 0:
			result += _get_collisions_recursive(child)
	return result

## @func_doc
## @description Recherche recursive de tous les MeshInstance3D dans l'arborescence d'un noeud donne.
## @param node: Node Noeud a partir duquel commencer la recherche.
## @return Array Liste des MeshInstance3D trouves.
## @tags utility, recursive
func _get_meshes_recursive(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is MeshInstance3D:
			result.append(child)
		if child.get_child_count() > 0:
			result += _get_meshes_recursive(child)
	return result

## @func_doc
## @description Verifie si l'objet peut etre place a sa position actuelle.
## La verification repose sur deux criteres: les Raycasts doivent toucher une surface,
## et l'Area3D ne doit chevaucher aucune autre zone.
## @return bool Vrai si le placement est valide, faux sinon.
## @tags placement, collision, validation
func check_placement() -> bool:
	# 1. Verification de la surface de support via Raycasts
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false
			
	# 2. Verification du chevauchement avec d'autres objets via Area3D
	if area.get_overlapping_areas():
		placement_red()
		return false
		
	# Placement valide
	placement_green()
	return true
		
## @func_doc
## @description Finalise le placement de l'objet.
## Retire le material de couleur temporaire (rouge/vert) et supprime les Raycasts temporaires.
## @return void
## @tags placement, cleanup
func placed() ->void:
	for mesh in meshes:
		mesh.material_override = null # Retire l'override pour restaurer le material original
	for ray in raycasts:
		ray.queue_free() # Supprime les rayons de verification temporaires

## @func_doc
## @description Change le material de tous les meshes en rouge pour indiquer un placement invalide.
## @return void
## @tags ui, placement, material
func placement_red() ->void:
	for mesh in meshes:
		mesh.material_override = red_mat
		
## @func_doc
## @description Change le material de tous les meshes en vert pour indiquer un placement valide.
## @return void
## @tags ui, placement, material
func placement_green() ->void:
	for mesh in meshes:
		mesh.material_override = green_mat
