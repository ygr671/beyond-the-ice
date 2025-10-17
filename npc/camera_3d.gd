extends Camera3D

var mouse = Vector2()
var target: Node3D = null
var move_speed = 5.0
@onready var ui_label: Label = $"../CanvasLayer/Label"
var normal_rotation: Basis
var target_rotation: Basis
var normal_position: Vector3

@onready var navigation_npc: CharacterBody3D = $"../NavigationNPC"


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mouse = event.position
		select_npc()

func _ready():
	# sauvegarde la position et rotation initiales de la caméra
	normal_position = global_position
	normal_rotation = global_transform.basis   # maintenant c'est correct
	target_rotation = normal_rotation
			
			

func select_npc():
	var space_state = get_world_3d().direct_space_state #Permet de questionner le monde 3D pour les collisions
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 1000.0
	var query = PhysicsRayQueryParameters3D.new() # créer un objet   Physics... pour définir un rayon
	query.from = from #debut
	query.to = to # fin du rayon
	var result = space_state.intersect_ray(query) #result contient les info sur l'objet toucché
	if result and result.has("collider") and result.collider is CharacterBody3D:
		if target == result.collider:
			# si on reclique sur le même NPC, on retourne à la caméra normale
			target.speed_boost()
			target = null
			ui_label.visible = false
		else:
			target = result.collider
			ui_label.text = target._display()
			ui_label.visible = true
			target._set_destination_null()

		
		
	

func _process(delta: float) -> void:
	if target:ctuel**, donc on le passe depuis le bouton
	scene_stack.append(new_scene_path) # on stocke le chemin qu'on quitte
		var target_position = target.global_position + Vector3(0, 2, 5)
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		# calculer la rotation cible via look_at
		var look_at_basis = (Transform3D().looking_at(target.global_position - global_position, Vector3.UP)).basis
		target_rotation = look_at_basis
	else:
		# revenir à la rotation normale
		target_rotation = normal_rotation
		global_position = normal_position

	# interpolation fluide entre rotation actuelle et rotation cible
	global_transform.basis = global_transform.basis.slerp(target_rotation, move_speed * delta)

		
