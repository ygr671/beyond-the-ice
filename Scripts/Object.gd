extends Node3D

@onready var raycasts = [$Mesh/ray1, $Mesh/ray2, $Mesh/ray3, $Mesh/ray4]
@onready var labelPrix = $Label3D
@export var meshes: Array[MeshInstance3D]
@onready var area = $Mesh/Area3D
@onready var green_mat = preload("res://materials/greenPlacement.tres")
@onready var red_mat = preload("res://materials/redPlacement.tres")
@onready var floatingLabel = $FloatingLabel
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

func show_depense(montant: int): #Fonction qui affiche une anim lors de l'achat d'un objet
	
	floatingLabel.text = "-" + str(montant) + " $"
	floatingLabel.modulate = Color(1, 0, 0, 1)  
	floatingLabel.visible = true
	floatingLabel.position = Vector3(0, 2, 0)  
	floatingLabel.scale = Vector3(0, 0, 0)     

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(floatingLabel, "scale", Vector3(1.2, 1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(floatingLabel, "scale", Vector3(1, 1, 1), 0.1).set_delay(0.2)
	tween.tween_property(floatingLabel, "position", floatingLabel.position + Vector3(0, 1, 0), 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(floatingLabel, "modulate:a", 0.0, 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): floatingLabel.visible = false)

func show_gain(montant: int): #Fonction qui affiche une anim lors de l'achat d'un objet
	floatingLabel.text = "+" + str(montant) + " $"
	floatingLabel.modulate = Color(0, 1, 0, 1)  
	floatingLabel.visible = true
	floatingLabel.position = Vector3(0, 2, 0)  
	floatingLabel.scale = Vector3(0, 0, 0)     

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(floatingLabel, "scale", Vector3(1.2, 1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(floatingLabel, "scale", Vector3(1, 1, 1), 0.1).set_delay(0.2)
	tween.tween_property(floatingLabel, "position", floatingLabel.position + Vector3(0, 1, 0), 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(floatingLabel, "modulate:a", 0.0, 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): floatingLabel.visible = false)
