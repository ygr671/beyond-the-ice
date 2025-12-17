## @class_doc
## @description Contrôleur principal de l'interface utilisateur (UI) et de l'interaction 3D.
## Gère le chargement et le placement des meubles, l'inventaire, les cycles de temps (Jour/Nuit/Meteo),
## la navigation entre les salles et les entrees utilisateur (clic, rotation, annulation).
## Tous les scripts UI specifiques aux pieces heritent de celui-ci.
## @tags ui, core, interaction, 3d, inventory, time_management

extends Control

## @onready_doc
## @description Reference a la scene principale du jeu.
## @tags nodes, scene
@onready var main_controller = get_tree().get_current_scene()

## @onready_doc
## @description reference au label d'icone a afficher lorsqu'il fait nuit pour dire quon ne peut pas faire de livrasions
@onready var delivery_label = $delivery_label
@onready var line_label = $line_label

## @onready_doc
## @description Reference au sous-menu de selection de couleur.
## @tags nodes, ui
@onready var color_menu = $ui_color_selection

## @onready_doc
## @description Reference au sous-menu de commande de meubles.
## @tags nodes, ui
@onready var order_menu = $ui_order_furniture

## @onready_doc
## @description Reference au panneau d'inventaire.
## @tags nodes, ui
@onready var inventory_menu = $ui_inventory

## @onready_doc
## @description Liste des nœuds de salle (Room) enfants du nœud "Salles" de la scene principale.
## @tags nodes, scene
@onready var salles = get_tree().get_current_scene().get_node("Salles").get_children() 

## @var_doc
## @description Reference a la liste de ressources d'information des meubles (copie de player_controller.furniture_list).
## @tags data, inventory
var furniture_list = player_controller.furniture_list

# --- Gestion du temps ---

## @var_doc
## @description Intervalle desire (en secondes) pour le changement du cycle Jour/Nuit.
## @tags config, time
const INTERVALLE_DESIRE_NUIT: float = 40.0

## @var_doc
## @description Intervalle desire (en secondes) pour le changement de la meteo.
## @tags config, time
const INTERVALLE_DESIRE_METEO: float = 25

## @var_doc
## @description Compteur de temps ecoule depuis le dernier changement Jour/Nuit.
## @tags state, time
var temps_ecoule_nuit: float = 0.0

## @var_doc
## @description Compteur de temps ecoule depuis le dernier changement de meteo.
## @tags state, time
var temps_ecoule_meteo:float = 0.0

# --- Gestion du placement ---

## @var_doc
## @description Index de la salle actuellement visualisee/activee.
## @tags state, room
var current_room = 0

## @var_doc
## @description Reference a la camera 3D du viewport.
## @tags nodes, camera
var camera

## @var_doc
## @description Reference a l'instance du meuble en cours de placement.
## @tags state, placement
var instance

## @var_doc
## @description Indicateur booleen si le joueur est en mode placement de meuble.
## @tags state, placement
var placing = false

## @var_doc
## @description Indicateur booleen si le meuble peut etre place a la position actuelle (verifie par Furniture.gd).
## @tags state, placement
var can_place = false

## @var_doc
## @description Indicateur booleen si le meuble est en cours de rotation (pour eviter le spam de rotation).
## @tags state, animation
var rotating = false

## @onready_doc
## @description Reference a la liste d'objets dans l'inventaire.
## @tags nodes, ui, inventory
@onready var item_list = $ui_inventory/Panel/ItemList

## @onready_doc
## @description Reference a la liste d'objets dans le menu de commande.
## @tags nodes, ui
@onready var order_list = $ui_order_furniture/Panel/ItemList


## @func_doc
## @description Retourne le nœud de la salle actuellement visible.
## @return Node Le nœud de la salle visible, ou null si aucune n'est visible.
## @tags utility, scene
func get_current_room():
	for room in get_tree().get_current_scene().get_children():
		if room.visible:
			return room
	return null

## @func_doc
## @description Initialisation du contrôleur: charge la camera, charge les meubles depuis le repertoire
## et met a jour les ItemList d'inventaire et de commande.
## @tags init, core
func _ready():
	delivery_label.focus_mode = Control.FOCUS_NONE
	line_label.focus_mode = Control.FOCUS_NONE
	camera = get_viewport().get_camera_3d()
	#load_furnitures_from_directory("user://furnitures") POUR L'EXPORT FINAL
	load_furnitures_from_directory("res://Meshes")
	
	# Mise a jour des listes d'inventaire et de commande
	for i in range(furniture_list.size()):
		var info = furniture_list[i]
		order_list.add_item("", info.image)
		if info.stock == 0:
			item_list.add_item("") # Affiche vide si pas de stock
		else:
			item_list.add_item(str(info.stock), info.image)
	# Connexion au signal d'environnement (si besoin d'actions specifiques ici)
	connect("environment_changed", Callable(self, "_on_environment_changed"))
	await get_tree().create_timer(0.2).timeout
	_on_salon_pressed()


## @func_doc
## @description Charge recursivement les scenes de meubles depuis le repertoire specifie.
## Cree et peuple les ressources FurnitureInfo pour chaque meuble trouve.
## @param path: String Chemin du repertoire a parcourir.
## @tags init, assets, data
func load_furnitures_from_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: " + path)
		return
	
	# Traitement des fichiers .tscn dans le repertoire
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			var full_path = path + "/" + file_name
			var scene = load(full_path)
			if scene:
				var inst = scene.instantiate()
				# Verification que l'instance est bien un meuble avec une logique de placement
				if inst.has_method("check_placement"):
					var info := FurnitureInfo.new()
					info.scene = scene
					info.name = file_name.get_basename()
					# Recupere les valeurs initiales du meuble instancie
					info.stock = inst.initial_stock
					info.restock_count = inst.restock_count
					
					# Chargement de l'image de l'inventaire
					var image_path := path + "/" + file_name.get_basename() + ".png"
					if ResourceLoader.exists(image_path):
						info.image = load(image_path)
					else:
						push_warning("Image introuvable : " + image_path)
						info.image = null

					furniture_list.append(info)
				# Nettoyage de l'instance temporaire
				inst.queue_free()

	# Recurrence pour les sous-repertoires
	for subdir_name in dir.get_directories():
		load_furnitures_from_directory(path + "/" + subdir_name)


## @func_doc
## @description Gestionnaire d'entrees non-gerees (clavier, souris).
## Gere le placement du meuble au clic gauche, la rotation du meuble (touche R ou molette),
## et l'annulation du placement/masquage des menus (echap ou clic droit).
## @param event: InputEvent Evenement d'entree non géré.
## @return void
## @tags input, placement, rotation, cancellation
func _unhandled_input(event: InputEvent) -> void:
	# --- Placement ---
	if event.is_action_pressed("left_click") and can_place:
		var index = item_list.get_selected_items()[0]
		placing = false
		can_place = false
		instance.placed() # Valide le placement dans le script du meuble
		
		var info = furniture_list[index]
		info.stock -= 1 # Met a jour le stock
		
		item_list.set_item_text(index, str(info.stock)) # Mise a jour UI
		
		# Emission du signal pour les PNJ
		player_controller.emit_signal("environment_changed", "furniture_placed", info.name)
		item_list.deselect_all()

		instance = null
		item_list.set_item_text(index, str(info.stock)) # Double mise a jour (redondant?)


	# --- Rotation (sens anti-horaire) ---
	if event.is_action_pressed("r") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN) and instance and placing and !rotating:
		rotating = true
		var startRotation = instance.rotation_degrees
		var targetRotation = startRotation
		targetRotation.y -= 90 # Rotation negative
		# Assure que la rotation est un multiple de 90 degres
		targetRotation.y = round(targetRotation.y / 90) * 90 
		
		var tween = create_tween()
		tween.tween_property(instance, "rotation_degrees", targetRotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func(): rotating = false)
		
	# --- Rotation (sens horaire) ---
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP) and instance and placing and !rotating:
		rotating = true
		var startRotation = instance.rotation_degrees
		var targetRotation = startRotation
		targetRotation.y -= -90 # Rotation positive
		targetRotation.y = round(targetRotation.y / 90) * 90
		
		var tween = create_tween()
		tween.tween_property(instance, "rotation_degrees", targetRotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func(): rotating = false)
		
	# --- Annulation / Fermeture de menus ---
	if (event.is_action_pressed('escape') or event.is_action_pressed("right_click")):
		color_menu.hide()
		order_menu.hide()
		inventory_menu.hide()
		if placing:
			can_place = false
			placing = false
			item_list.deselect_all()
			if instance:
				instance.queue_free()
				instance = null

## @func_doc
## @description Affiche un texte flottant anime (gain/perte d'argent) au-dessus d'une position.
## (NOTE: Cette fonction est presente mais non utilisee pour les NPC, ils utilisent leur propre logique d'emoji).
## @param montant: int Montant positif ou negatif a afficher.
## @param pos: Vector3 Position dans l'espace 3D ou afficher le texte.
## @param parent: Node Nœud parent pour l'ajout du Label3D.
## @tags ui, animation, feedback
func show_floating_text(montant: int, pos: Vector3, parent: Node):
	var label = Label3D.new()
	label.text = ("+" + str(montant) if montant >= 0 else str(montant)) + " $"
	label.modulate = Color(0,1,0,1) if montant >= 0 else Color(1,0,0,1) # Vert pour gain, Rouge pour perte
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = pos + Vector3(0,2,0)
	label.scale = Vector3(0,0,0)
	parent.add_child(label)

	# Creation et execution de l'animation
	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector3(1.2,1.2,1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(1,1,1), 0.1).set_delay(0.2)
	tween.tween_property(label, "position", label.position + Vector3(0,1,0), 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): label.queue_free())

## @func_doc
## @description Mise a jour par frame : gere le cycle Jour/Nuit/Meteo par intervalle de temps
## et met a jour la position du meuble en cours de placement via un Raycast 3D.
## @param _delta: float Temps ecoule depuis la derniere frame.
## @tags core, time, placement, raycast
func _process(_delta: float) -> void:
	# --- Gestion des cycles de temps ---
	temps_ecoule_nuit += _delta
	temps_ecoule_meteo+=_delta
	
	if temps_ecoule_nuit >= INTERVALLE_DESIRE_NUIT:
		cycle()
		temps_ecoule_nuit -= INTERVALLE_DESIRE_NUIT
		
	if temps_ecoule_meteo >= INTERVALLE_DESIRE_METEO:
		weather_cycle()
		temps_ecoule_meteo-=INTERVALLE_DESIRE_METEO
		
	# --- Suivi du curseur pour le placement ---
	if placing:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
		
		# Creation et execution du Raycast
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var colision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		
		if colision:
			instance.transform.origin = colision.position # Positionne le meuble sur le point de collision
			can_place = instance.check_placement() # Verifie la validite du placement (via Furniture.gd)
			

## @func_doc
## @description Annule le dernier placement de meuble dans la salle actuelle.
## Supprime l'objet, met a jour le stock et emet un signal de retrait d'environnement.
## @return void
## @tags placement, undo, inventory, signal
func undo_placement() -> void:
	var placed = salles[current_room].get_node("PlacedObjects")
	if placed.get_child_count() == 0:
		return
	
	# Recupere le dernier enfant place
	var lastObject = placed.get_child(placed.get_child_count() - 1)
	var index = lastObject.get_meta("furniture_index")
	var info = furniture_list[index]

	info.stock += 1 # Restaure le stock

	item_list.set_item_text(index, str(info.stock)) # Mise a jour UI

	# Emission du signal pour les PNJ
	player_controller.emit_signal("environment_changed", "furniture_removed", info.name)

	lastObject.queue_free() # Suppression de l'objet


## @func_doc
## @description Appelé lors de l'appui sur un bouton d'annulation (distinct de l'annulation de placement).
## Si le joueur n'est pas en mode placement, appelle la fonction d'annulation de placement.
## @return void
## @tags ui, undo
func _on_button_pressed() -> void:
	if !placing:
		undo_placement()
		
# --- Gestionnaire de Scenes (Non utilise ici, mais present pour une gestion generique) ---

## @var_doc
## @description Reference a la scene active.
## @tags state, scene
var current_scene : Node = null

## @var_doc
## @description Dictionnaire pour stocker les instances de scenes deja creees (caching).
## @tags state, scene
var scenes = {} 

## @func_doc
## @description Charge une scene de maniere optimisee, en la cachant/affichant si deja instanciee.
## @param path: String Chemin de la scene a charger.
## @return void
## @tags scene, caching
func _load_scene(path: String) -> void:
	# Cacher l'ancienne scene
	if current_scene:
		current_scene.hide()

	# Si la scene n’a pas encore ete instanciee, on la cree
	if not scenes.has(path):
		var scene_instance = load(path).instantiate()
		add_child(scene_instance)
		scenes[path] = scene_instance

	# Afficher la scene demandee
	current_scene = scenes[path]
	current_scene.show()

## @func_doc
## @description Active ou desactive la couche et le masque de collision pour tous les objets CollisionObject3D
## dans une piece donnee, y compris recursivement dans les sous-nœuds.
## @param room: Node Nœud de la piece a modifier.
## @param active: bool True pour activer (couche 1), False pour desactiver (couche 0).
## @tags physics, utility, collision
func set_room_collision_active(room, active: bool):
	for node in room.get_children():
		if node is CollisionObject3D:
			# Active/Desactive la collision pour le Raycast de placement
			node.collision_layer = 1 if active else 0
			node.collision_mask = 1 if active else 0
		
		# Recurrence pour enfants plus profonds
		if node.get_child_count() > 0:
			set_room_collision_active(node, active)
			
## @func_doc
## @description Active la salle specifiee par index et desactive toutes les autres.
## Met a jour player_controller.current_room et gere l'activation/desactivation des collisions.
## @param index: int Index de la salle a selectionner.
## @return void
## @tags room, navigation, core
func room_selection(index: int) -> void:
	player_controller.current_room = index
	for i in range(salles.size()-1):
		var active = (i == index)
		salles[i].visible = active
		salles[i].set_process(active)
		set_room_collision_active(salles[i], active) # Gere les collisions pour le Raycast
	
		var buttons = $PanelSalles/HBoxContainer.get_children()
		for y in range(buttons.size()):
			var button = buttons[y]
			if button is Button:
				if y == current_room:
					var style = button.get_theme_stylebox("normal_mirrored", "Button")
					button.add_theme_stylebox_override("normal", style)
					button.add_theme_color_override("font_color", Color("5cffff"))
				else:
					var default_style = button.get_theme_stylebox("normal", "Button")
					button.add_theme_stylebox_override("normal", default_style)
					button.add_theme_color_override("font_color", Color("ffff"))
	

	await get_tree().process_frame # Attend une frame pour s'assurer des mises a jour

# --- Fonctions de Selection de Salle (liees aux boutons UI) ---

## @func_doc
## @description Selectionne la salle 'Salon' (index 0).
## @tags ui, navigation, room
func _on_salon_pressed() -> void:
	current_room = 0
	room_selection(current_room)
	_deselect_item()

## @func_doc
## @description Selectionne la salle 'Salle de Bain' (index 1).
## @tags ui, navigation, room
func _on_salle_de_bain_pressed() -> void:
	current_room = 1
	room_selection(current_room)
	_deselect_item()
	
## @func_doc
## @description Selectionne la salle 'Cuisine' (index 2).
## @tags ui, navigation, room
func _on_cuisine_pressed() -> void:
	current_room = 2
	room_selection(current_room)
	_deselect_item()
	
## @func_doc
## @description Selectionne la salle 'Chambre' (index 3).
## @tags ui, navigation, room
func _on_chambre_pressed() -> void:
	current_room = 3
	room_selection(current_room)
	_deselect_item()
	
## @func_doc
## @description Selectionne la salle 'Laboratoire' (index 4).
## @tags ui, navigation, room
func _on_laboratoire_pressed() -> void:
	current_room = 4
	room_selection(current_room)
	_deselect_item()

## @func_doc
## @description Selectionne la salle 'Stockage' (index 5).
## @tags ui, navigation, room
func _on_stockage_pressed() -> void:
	current_room = 5
	room_selection(current_room)
	_deselect_item()
	
## @func_doc
## @description Annule le placement et masque les menus UI pour nettoyer l'interface.
## @tags ui, cleanup, placement
func _deselect_item():
	placing = false
	can_place = false
	item_list.deselect_all()
	if is_instance_valid(instance):
		instance.queue_free()
	color_menu.hide()

## @func_doc
## @description Affiche le menu de selection de couleur et masque les autres menus UI.
## @tags ui, navigation
func _on_button_open_color_pressed() -> void:
	color_menu.show()
	order_menu.hide()
	inventory_menu.hide()


## @func_doc
## @description Appelle la fonction de bascule Jour/Nuit sur le controleur principal de scene.
## @tags time, core
func cycle():
	if main_controller and main_controller.has_method("toggle_day_night"):
		main_controller.toggle_day_night()
		if !player_controller.is_day:
			delivery_label.show()
			line_label.show()
		else:
			delivery_label.hide()
			line_label.hide()
		
	else:
		print("Erreur: Le contrôleur principal n'a pas la fonction 'toggle_day_night' ou n'est pas chargé.")

## @func_doc
## @description Appelle la fonction de bascule de meteo sur le controleur principal de scene.
## @tags time, core
func weather_cycle():
	main_controller.toggle_good_bad_weather()

## @func_doc
## @description Appelé lorsqu'un element de l'inventaire est selectionne par le joueur.
## Initialise le mode placement pour le meuble selectionne, a condition qu'il y ait du stock
## et que le nombre maximum d'objets (4) n'ait pas ete atteint dans la salle.
## @param index: int Index de l'element selectionne dans la liste.
## @tags ui, inventory, placement
func _on_item_list_item_selected(index: int) -> void:
	# Verifie le stock
	if furniture_list[index].stock == 0:
		item_list.deselect_all()
		return

	# Verifie le nombre max d'objets dans la salle (limite a 4)
	if salles[current_room].get_node("PlacedObjects").get_child_count() >= 4:
		item_list.deselect_all()
		return
		
	# Nettoie l'instance precedente si elle etait en cours de placement
	if placing:
		instance.queue_free()
		
	var info = furniture_list[index]

	# Chargement et instantiation du meuble
	instance = info.scene.instantiate()
	instance.set_meta("furniture_index", index) # Stocke l'index du meuble pour l'annulation

	placing = true
	inventory_menu.hide()
	# Ajoute le meuble a un nœud PlacedObjects de la salle actuelle
	salles[current_room].get_node("PlacedObjects").add_child(instance)
