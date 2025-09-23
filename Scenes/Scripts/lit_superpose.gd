extends Node3D

@onready var raycasts = [$Mesh/ray1, $Mesh/ray2, $Mesh/ray3, $Mesh/ray4]
@export var meshes : Array[MeshInstance3D]
@onready var area = $Mesh/Area3D
@onready var green_mat = preload("res://materials/greenPlacement.tres")
@onready var red_mat = preload("res://materials/redPlacement.tres")
@export var price = 50

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


func placement_red() ->void:
	for mesh in meshes:
		mesh.material_override = red_mat
		
func placement_green() ->void:
	for mesh in meshes:
		mesh.material_override = green_mat 
