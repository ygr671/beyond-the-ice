extends Control

@onready var litSimple = preload("res://Meshes/litSimple.tscn")
@onready var litDouble = preload("res://Meshes/litDouble.tscn")
@onready var litSuperpose = preload("res://Meshes/litSuperpose.tscn")

@onready var placedObjects = get_tree().get_current_scene().get_node("PlacedObjects")
@onready var infoBubble = $InfoBubble


var camera
var instance
var placing = false
var can_place = false
var money:int = 1000
var lastExpenses: Array[int]
var rotating = false # Pour l'anim sinon on peut spam
@onready var item_list = $ItemList
@onready var labelMoney = $Label

func _ready():
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
	placedObjects.add_child(instance)

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
	if placedObjects.get_child_count() > 0 and lastExpenses.size() > 0:
			var lastObject = placedObjects.get_child(placedObjects.get_child_count() - 1)
			var sum = lastObject.price
			add_money(lastExpenses.pop_back())
			show_floating_text(sum, lastObject.global_transform.origin, get_tree().current_scene)
			lastObject.queue_free()


func _on_button_pressed() -> void:
	if !placing:
		undo_placement()
