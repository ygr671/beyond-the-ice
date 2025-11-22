extends Node3D

@onready var raycasts = [$Mesh/ray1, $Mesh/ray2, $Mesh/ray3, $Mesh/ray4]
@export var meshes: Array[MeshInstance3D]
@onready var area = $Mesh/Area3D
@onready var green_mat = preload("res://materials/Object/green_placement.tres")
@onready var red_mat = preload("res://materials/Object/red_placement.tres")
var angle: float = 0

func _ready() -> void:
	meshes.clear()
	for child in get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		elif child.get_child_count() > 0:
			meshes += _get_meshes_recursive(child)


func _get_meshes_recursive(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is MeshInstance3D:
			result.append(child)
		if child.get_child_count() > 0:
			result += _get_meshes_recursive(child)
	return result

func check_placement() -> bool:
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false
	
	if area.get_overlapping_areas():
		placement_red()
		return false
	
	placement_green()
	return true
	
func placed() ->void:
	for mesh in meshes:
		mesh.material_override = null
	for ray in raycasts:
		ray.queue_free()
	create_collision()

func create_collision():
	# Créer le StaticBody3D
	var static_body = StaticBody3D.new()
	
	# Créer le CollisionShape3D
	var collision_shape = CollisionShape3D.new()
	
	# Copier la forme de collision de l'Area3D
	var area_collision = area.get_child(0)  # Le premier enfant de l'Area3D
	if area_collision is CollisionShape3D:
		collision_shape.shape = area_collision.shape.duplicate()
	
	# Assembler la hiérarchie
	static_body.add_child(collision_shape)
	add_child(static_body)
	
	# Positionner au même endroit que l'objet
	static_body.global_transform = global_transform


func placement_red() ->void:
	for mesh in meshes:
		mesh.material_override = red_mat
		
func placement_green() ->void:
	for mesh in meshes:
		mesh.material_override = green_mat 
