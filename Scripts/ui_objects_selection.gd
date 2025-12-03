extends Control

@onready var bed = preload("res://Meshes/beds/bed.tscn")
@onready var large_bed = preload("res://Meshes/beds/large_bed.tscn")
@onready var bunk_bed = preload("res://Meshes/beds/bunk_bed.tscn")
@onready var main_controller = get_tree().get_current_scene()

@onready var chair = preload("res://Meshes/living_room/chair.tscn")
@onready var pc_setup = preload("res://Meshes/living_room/pc_setup.tscn")
@onready var wheel_chair = preload("res://Meshes/Laboratory/wheel_chair.tscn")

@onready var color_menu = $ui_color_selection

@onready var salles = get_tree().get_current_scene().get_node("Salles").get_children() 

var current_room = 0
var furniture_type
var camera
var instance
var placing = false
var can_place = false
var rotating = false # Pour l'anim sinon on peut spam
@onready var item_list = $ItemList


func get_current_room():
	for room in get_tree().get_current_scene().get_children():
		if room.visible:
			return room
	return null

func _ready():
	camera = get_viewport().get_camera_3d()
	room_selection(0)
	player_controller.connect("environment_changed", Callable(self, "_on_environment_changed"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and can_place:
		placing = false
		can_place = false
		instance.placed()
		player_controller.emit_signal("environment_changed", "furniture_placed", furniture_type)
		match furniture_type :
			"lit_superpose":
				player_controller.bed_in_invetory -= 1
		item_list.deselect_all()
		instance = null

	if event.is_action_pressed("r") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN) and instance and placing and !rotating:
		rotating = true
		var startRotation = instance.rotation_degrees
		var targetRotation = startRotation
		targetRotation.y -= 90 
		targetRotation.y = round(targetRotation.y / 90) * 90 #pour rester sur des multiple de 90° sinon c'est buggger a mort
		
		var tween = create_tween()
		tween.tween_property(instance, "rotation_degrees", targetRotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func(): rotating = false)
	
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP) and instance and placing and !rotating:
		rotating = true
		var startRotation = instance.rotation_degrees
		var targetRotation = startRotation
		targetRotation.y -= -90 
		targetRotation.y = round(targetRotation.y / 90) * 90 #pour rester sur des multiple de 90° sinon c'est buggger a mort
		
		var tween = create_tween()
		tween.tween_property(instance, "rotation_degrees", targetRotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func(): rotating = false)
	
	if (event.is_action_pressed('escape') or event.is_action_pressed("right_click")):
		color_menu.hide()
		if can_place:
			can_place = false
			placing = false
			item_list.deselect_all()
			if instance:
				instance.queue_free()
				instance = null

# Note : utiliser ça pour l'émoji ou une réction instantée d'un NPC dans son code ? 
func show_floating_text(montant: int, pos: Vector3, parent: Node):
	var label = Label3D.new()
	label.text = ("+" + str(montant) if montant >= 0 else str(montant)) + " $"
	label.modulate = Color(0,1,0,1) if montant >= 0 else Color(1,0,0,1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = pos + Vector3(0,2,0)
	label.scale = Vector3(0,0,0)
	parent.add_child(label)

	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector3(1.2,1.2,1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(1,1,1), 0.1).set_delay(0.2)
	tween.tween_property(label, "position", label.position + Vector3(0,1,0), 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): label.queue_free())

func _process(_delta: float) -> void:
	if placing:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var colision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if colision:
			instance.transform.origin = colision.position
			can_place = instance.check_placement()


func _on_item_list_item_selected(index: int) -> void:
	print(player_controller.bed_in_invetory)
	if player_controller.bed_in_invetory == 0 && index == 0:
		item_list.deselect_all()
		return
	if salles[current_room].get_node("PlacedObjects").get_child_count() >= 4:
		item_list.deselect_all()
		return
		
	if placing:
		instance.queue_free()
	if index == 0: 
		instance = bunk_bed.instantiate()
		furniture_type = "lit_superpose"
	if index == 1:
		instance = pc_setup.instantiate()
		furniture_type = "pc_gaming"
	if index == 2: 
		instance = wheel_chair.instantiate()
		furniture_type = "wheel_chair"
		
	instance.set_meta("furniture_type", furniture_type)	
	
	placing = true
	
	salles[current_room].get_node("PlacedObjects").add_child(instance)
	
	
	

func undo_placement() -> void:
	var placed = salles[current_room].get_node("PlacedObjects")

	if placed.get_child_count() == 0:
		return
	
	var lastObject = placed.get_child(placed.get_child_count() - 1)
	
	furniture_type = lastObject.get_meta("furniture_type")
	player_controller.emit_signal("environment_changed", "furniture_removed", furniture_type)
	player_controller.bed_in_invetory +=1 
	lastObject.queue_free()


func _on_button_pressed() -> void:
	if !placing:
		undo_placement()
		

var current_scene : Node = null
var scenes = {}  # dictionnaire pour stocker les instances déjà créées

func _load_scene(path: String) -> void:
	# Cacher l'ancienne scène
	if current_scene:
		current_scene.hide()

	# Si la scène n’a pas encore été instanciée, on la crée
	if not scenes.has(path):
		var scene_instance = load(path).instantiate()
		add_child(scene_instance)
		scenes[path] = scene_instance

	# Afficher la scène demandée
	current_scene = scenes[path]
	current_scene.show()

func set_room_collision_active(room, active: bool):
	for node in room.get_children():
		if node is CollisionObject3D:
			node.collision_layer = 1 if active else 0
			node.collision_mask = 1 if active else 0
		
		# Récursion pour enfants plus profonds
		if node.get_child_count() > 0:
			set_room_collision_active(node, active)
			

func room_selection(index: int) -> void:
	player_controller.current_room = index
	for i in range(salles.size()-1):
		var active = (i == index)
		salles[i].visible = active
		salles[i].set_process(active)
		set_room_collision_active(salles[i], active)

	await get_tree().process_frame
	
func _on_salon_pressed() -> void:
	# On set "l'index" de la salle
	current_room = 0
	room_selection(current_room)
	_deselect_item()

func _on_salle_de_bain_pressed() -> void:
	current_room = 1
	room_selection(current_room)
	_deselect_item()
	
func _on_cuisine_pressed() -> void:
	current_room = 2
	room_selection(current_room)
	_deselect_item()
	
func _on_chambre_pressed() -> void:
	current_room = 3
	room_selection(current_room)
	_deselect_item()
	
func _on_laboratoire_pressed() -> void:
	current_room = 4
	room_selection(current_room)
	_deselect_item()

func _on_stockage_pressed() -> void:
	current_room = 5
	room_selection(current_room)
	_deselect_item()
	
func _deselect_item():
	placing = false
	can_place = false
	item_list.deselect_all()
	if is_instance_valid(instance):
		instance.queue_free()
	color_menu.hide()

func _on_button_open_color_pressed() -> void:
	color_menu.show()


func _on_cycle_pressed() -> void:
	# 💥 NOUVELLE LOGIQUE : Appeler la fonction Jour/Nuit du contrôleur principal
	if main_controller and main_controller.has_method("toggle_day_night"):
		main_controller.toggle_day_night()
	else:
		# Ceci vous aidera à déboguer si le script Jour/Nuit n'est pas trouvé
		print("Erreur: Le contrôleur principal n'a pas la fonction 'toggle_day_night' ou n'est pas chargé.")
