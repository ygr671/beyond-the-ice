extends Control

@onready var litSimple = preload("res://Meshes/litSimple.tscn")
@onready var litDouble = preload("res://Meshes/litDouble.tscn")
@onready var litSuperpose = preload("res://Meshes/litSuperpose.tscn")

@onready var placedObjects = get_tree().get_current_scene().get_node("PlacedObjects")

var camera
var instance
var placing = false
var range = 1000
var can_place = false

@onready var item_list = $ItemList

func _ready():
	camera = get_viewport().get_camera_3d()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and can_place:
		placing = false
		can_place = false
		instance.placed()
		item_list.deselect_all()
		
	if event.is_action_pressed("r") and instance:
		var rot = instance.rotation_degrees
		rot.y -= 90
		instance.rotation_degrees = rot
		
	if event.is_action_pressed('escape') and can_place:
		can_place = false
		placing = false
		item_list.deselect_all()
		if instance:
			instance.queue_free()
			instance = null
	if event.is_action_pressed("undo"):
		if placedObjects.get_child_count() > 0:
			var lastObject = placedObjects.get_child(placedObjects.get_child_count() - 1)
			lastObject.queue_free()
	


func _process(delta: float) -> void:
	if placing:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var colision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if colision:
			instance.transform.origin = colision.position
			can_place = instance.check_placement()


func _on_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()
	if  index == 0: 
		instance = litSuperpose.instantiate()
	if index == 1:
		instance = litSimple.instantiate()
	if index == 2: 
		instance = litDouble.instantiate()
	
	placing = true
	placedObjects.add_child(instance)
