extends Node3D

@onready var raycasts = [$Mesh/ray1, $Mesh/ray2, $Mesh/ray3, $Mesh/ray4]
@onready var labelPrix = $Label3D
@export var meshes: Array[MeshInstance3D]
@onready var area = $Mesh/Area3D
@onready var green_mat = preload("res://materials/greenPlacement.tres")
@onready var red_mat = preload("res://materials/redPlacement.tres")
@export var price = 0
var angle: float = 0

func _ready() -> void:
	meshes.clear()
	for child in get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		elif child.get_child_count() > 0:
			meshes += _get_meshes_recursive(child)
	labelPrix.text = str(price) + "$"


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
	labelPrix.visible = false


func placement_red() ->void:
	for mesh in meshes:
		mesh.material_override = red_mat
		
func placement_green() ->void:
	for mesh in meshes:
		mesh.material_override = green_mat 
		
