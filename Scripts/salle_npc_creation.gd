## @class_doc
## @description Gestionnaire d'une salle (Room) dans le jeu.
## Ce script est responsable de l'instanciation aleatoire des PNJ a l'initialisation,
## de la gestion des MeshInstance3D des murs de la salle, et de la propagation des
## changements d'environnement (couleur) au PlayerController.
## @tags room, environment, npc, init

extends Node3D

## @export_doc
## @description Scene prechargee du PNJ a instancier dans la salle.
## @type PackedScene
## @tags config, npc
@export var npc_scene: PackedScene = preload("res://Scenes/navigation_npc.tscn")

## @onready_doc
## @description Reference au MeshInstance3D du mur droit.
## @tags nodes, wall
@onready var right_wall = $"Mur_droit/MeshInstance3D"

## @onready_doc
## @description Reference au MeshInstance3D du mur gauche.
## @tags nodes, wall
@onready var left_wall = $"Mur_gauche/MeshInstance3D"

## @func_doc
## @description Initialisation de la salle.
## Determine un nombre aleatoire de PNJ (1 a 4), les instancie, les configure,
## les positionne aleatoirement dans la salle et connecte le PNJ au PlayerController.
## @return void
## @tags init, npc, setup
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	var nb_npc = rng.randi_range(1, 4)
	
	for i in range(nb_npc):
		# Instanciation et setup du PNJ
		var npc = npc_scene.instantiate() as NavigationNPC
		# Assigne l'index de la salle au PNJ pour la verification des reactions
		npc.room_index = get_parent().get_index() 
		add_child(npc)
		npc.setup("Nils", "Nils", "😁")
		
		# Positionnement aleatoire du PNJ dans un carre de 5x5
		var random_x = randf_range(0.0, 5.0)
		var random_z = randf_range(0.0, 5.0)
		npc.global_position = global_position + Vector3(random_x, 0, random_z)
		
	# La salle elle-meme ecoute les changements d'environnement (par exemple, pour la couleur)
	player_controller.connect("environment_changed", Callable(self, "_on_environment_changed"))

## @func_doc
## @description Change la couleur des murs de la salle et emet un signal via le PlayerController.
## Cette fonction est utilisee par l'interface utilisateur pour declencher la couleur.
## @param material_ressource: StandardMaterial3D Le material a appliquer aux murs.
## @param color_name: String Nom de la couleur pour le signal (non utilise si le type est Color).
## @return void
## @tags ui, material, signaling
func set_wall_color(material_ressource: StandardMaterial3D, color_name: String):
	var targets = [right_wall, left_wall]
	for target in targets:
		if is_instance_id_valid(target):
			# Utilisation de set_surface_override_material pour appliquer le material
			target.set_surface_override_material(0, material_ressource)
			
	# Emission du signal pour que les PNJ de toutes les pieces puissent potentiellement reagir
	player_controller.emit_signal("environment_changed", "color_changed", color_name)
	
## @func_doc
## @description Réagit aux changements d'environnement emis par le PlayerController.
## S'assure que la salle n'agit que si c'est la piece actuellement vue par le joueur.
## Effectue des manipulations de mesh/material pour permettre le changement de couleur unique par mur.
## @param change_type: String Type de changement (ex: "color_changed").
## @param data: Variant Donnee associee (ex: Color).
## @return void
## @tags environment, events
func _on_environment_changed(change_type, data):
	var room_index = get_parent().get_index()
	# Verifie si le changement concerne la piece actuelle du joueur
	if room_index != player_controller.current_room:
		return
		
	var targets = [right_wall, left_wall]
	
	match change_type:
		"color_changed":
			for wall_mesh in targets:
				# Duplication de la Mesh pour s'assurer que le changement de material
				# ne se propage pas a d'autres MeshInstance3D partageant la meme Mesh
				if wall_mesh.mesh:
					var unique_mesh = wall_mesh.mesh.duplicate(true)
					wall_mesh.mesh = unique_mesh
					
				var unique_mat = StandardMaterial3D.new()
				
				# Applique la couleur si les donnees sont de type Color
				if typeof(data) == TYPE_COLOR:
					unique_mat.albedo_color = data
				else:
					# Cas par defaut si la couleur n'est pas une Color (e.g., Magenta)
					unique_mat.albedo_color = Color.MAGENTA
					
				wall_mesh.material_override = unique_mat
