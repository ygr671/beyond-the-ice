extends Control

@onready var litSimple = preload("res://Meshes/litSimple.tscn")
@onready var litDouble = preload("res://Meshes/litDouble.tscn")
@onready var litSuperpose = preload("res://Meshes/litSuperpose.tscn")

# @onready var salles = get_tree().current_scene.get_node("Salles")

@onready var salles = get_tree().get_current_scene().get_children() 

@onready var salon = salles[0]
@onready var salle_de_bain = salles[1]

@onready var infoBubble = $InfoBubble

var current_room = 0
var camera
var instance
var placing = false
var can_place = false
var money:int = 1000
var lastExpenses: Array[int]
var rotating = false # Pour l'anim sinon on peut spam
@onready var item_list = $ItemList
@onready var labelMoney = $Label

func get_current_room():
	for room in get_tree().get_current_scene().get_children():
		if room.visible:
			return room
	return null

func _ready():
	lastExpenses = []
	camera = get_viewport().get_camera_3d()
	set_money(money);	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and can_place:
		if enough_money(instance.price):
			add_money(-lastExpenses[lastExpenses.size()-1])
			placing = false
			can_place = false
			instance.placed()
			item_list.deselect_all()
			show_floating_text(-instance.price, instance.global_transform.origin, get_tree().current_scene)
		else:
			show_info_bubble()


	if event.is_action_pressed("r") and instance and placing and !rotating:
		rotating = true
		var startRotation = instance.rotation_degrees
		var targetRotation = startRotation
		targetRotation.y -= 90 
		targetRotation.y = round(targetRotation.y / 90) * 90 #pour rester sur des multiple de 90° sinon c'est buggger a mort
		
		var tween = create_tween()
		tween.tween_property(instance, "rotation_degrees", targetRotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func(): rotating = false)
		
	if (event.is_action_pressed('escape') or event.is_action_pressed("right_click") )and can_place:
		can_place = false
		placing = false
		item_list.deselect_all()
		if instance:
			instance.queue_free()
			instance = null
	if event.is_action_pressed("undo") and !placing:
		undo_placement()

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
	
	if infoBubble.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		infoBubble.position = mouse_pos + Vector2(-192, -35)


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
	
	salles[current_room].get_node("PlacedObjects").add_child(instance)

func set_money(value: int):
	labelMoney.text = "Money : " + str(value)

func add_money(value: int):
	money += value
	set_money(money)

func enough_money(price: int) -> bool:
	if (money - price) >= 0:
		lastExpenses.append(price)
		return true
	return false
	
func show_info_bubble() -> void:
	infoBubble.visible = true
	await get_tree().create_timer(3).timeout
	infoBubble.visible = false
	
func undo_placement() -> void:
	var placed = salles[current_room].get_node("PlacedObjects")

	if placed.get_child_count() == 0:
		return
	if lastExpenses.size() == 0:
		return
	
	var lastObject = placed.get_child(placed.get_child_count() - 1)
	var sum = lastObject.price

	add_money(lastExpenses.pop_back())
	show_floating_text(sum, lastObject.global_transform.origin, get_tree().current_scene)
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
	for i in range(salles.size()):
		var active = (i == index)
		salles[i].visible = active
		salles[i].set_process(active)
		
		set_room_collision_active(salles[i], active)

	await get_tree().process_frame
	
func _on_salon_pressed() -> void:
	# On set "l'index" de la salle
	current_room = 0
	room_selection(current_room)

func _on_salle_de_bain_pressed() -> void:
	current_room = 1
	room_selection(current_room)
	
func _on_chambre_pressed() -> void:
	current_room = 2
	room_selection(current_room)

func _on_cuisine_pressed() -> void:
	current_room = 3
	room_selection(current_room)

func _on_laboratoire_pressed() -> void:
	current_room = 4
	room_selection(current_room)

func _on_stockage_pressed() -> void:
	current_room = 5
	room_selection(current_room)
