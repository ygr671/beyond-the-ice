## @class_doc
## @description Controleur d'un personnage non-joueur (NPC) utilisant la navigation 3D.
## Gère le déplacement autonome du PNJ, sa satisfaction en fonction des changements 
## d'environnement (couleurs, placement/retrait de meubles) et l'affichage d'émoticônes.
## @tags npc, navigation, ia, environnement

extends CharacterBody3D
class_name NavigationNPC

## @depends player_controller: uses Se connecte à ses signaux pour les changements d'environnement
## @tags dependencies

## @onready_doc
## @description Agent de navigation 3D responsable du calcul et du suivi du chemin.
## @tags nodes, navigation
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

## @onready_doc
## @description Référence au modèle 3D du PNJ pour les manipulations visuelles.
## @tags nodes, visuals
@onready var model = $MeshInstance3D

## @export_doc
## @description Nom affiché du PNJ, configurable dans l'éditeur.
## @tags editor, config
@export var npc_name: String = "NPC"

## @export_doc
## @description Émoji de base affiché par le PNJ.
## @tags editor, config, visuals
@export var emoji: String = "😐"

## @var_doc
## @description Référence à l'objet Label3D actuel affichant l'émoji animé.
## Utilisé pour le nettoyage après l'animation.
## @tags runtime, visuals
var current_emoji: Label3D = null

## @var_doc
## @description Valeur de satisfaction actuelle (0-100), clampée après vérification.
## @tags state, core
var satisfaction = 35

## @var_doc
## @description Valeur de satisfaction brute, utilisée pour les calculs avant d'être montrée dans 'satisfaction'.
## @tags state
var real_satisfaction = satisfaction

## @var_doc
## @description Valeur de satisfaction du pnj par rapport a l'intensité de la lumiere
## @tags state
var light_intensity_satisfaction = 0

## @var_doc
## @description Valeur de satisfaction du pnj par rapport a la chaleur de la lumiere
## @tags state
var light_heat_satisfaction = 0

## @var_doc
## @description Index de la salle où se trouve actuellement le PNJ.
## Utilisé pour les vérifications de pertinence des meubles.
## @tags state, room
var room_index: int = 0




## @var_doc
## @description Nombre actuel de lits dans la pièce.
var nblits = 0
## @var_doc
## @description Nombre actuel de placards (closet) dans la pièce.
var nb_closet = 0
## @var_doc
## @description Nombre actuel de chaises (wheel_chair/chair) dans la pièce.
var nb_chair = 0
## @var_doc
## @description Nombre actuel de tables dans la pièce.
var nb_table = 0
## @var_doc
## @description Nombre actuel de canapés (sofa) dans la pièce.
var nb_sofa = 0
## @var_doc
## @description Nombre actuel de machines à laver dans la pièce.
var nb_washing = 0
## @var_doc
## @description Nombre actuel d'équipements de gym dans la pièce.
var nb_gym = 0
## @var_doc
## @description Nombre actuel de PC setups dans la pièce.
var nb_pc = 0
## @var_doc
## @description Nombre actuel de PC setups dans la pièce.
var nb_toilet = 0
## @var_doc
## @description Nombre actuel de PC setups dans la pièce.
var nb_sink = 0
## @var_doc
## @description Nombre actuel de PC setups dans la pièce.
var nb_shower = 0

## @var_doc
## @description Timer non utilisé dans le code actuel, mais réservé pour une éventuelle gestion du temps des émojis.
## @tags cleanup
var emoji_timer: Timer 

## @func_doc
## @description Initialise le PNJ : connecte au signal d'environnement et affiche l'émoji de base.
## @tags init, core
func _ready():
	# Nécessite que 'player_controller' soit défini et accessible globalement
	player_controller.connect("environment_changed", Callable(self, "_on_environment_changed"))
	show_animated_emoji(emoji, self)

## @func_doc
## @description Modifie la satisfaction du PNJ et met à jour l'émoji en fonction de l'impact du changement.
## La valeur finale de 'satisfaction' est toujours limitée entre 0 et 100.
## @param valeur: int La quantité de changement à appliquer à la satisfaction (positif ou négatif).
## @tags state, core
func change_satisfaction(valeur: int):
	real_satisfaction += valeur
	# Limite la satisfaction entre 0 et 100
	if real_satisfaction >= 0 && real_satisfaction <= 100:
		satisfaction = real_satisfaction
	elif real_satisfaction <= 0:
		satisfaction = 0
	else:
		satisfaction = 100

	var current_emoji_text = emoji
	# Logique pour changer l'émoji en fonction de la valeur de changement
	if valeur >= 15:
		current_emoji_text = "😇" # Grande joie
	elif valeur >= 0: # Devrait probablement être 'elif valeur > 0:' pour une petite joie
		current_emoji_text = "😊" # Petite joie

	elif valeur <=0: 
		current_emoji_text = "😟" # Petite tristesse
	elif valeur <= -15:
		current_emoji_text = "🤬" # Grande colère
			
	show_animated_emoji(current_emoji_text, self)

## @func_doc
## @description Réagit aux changements d'environnement émis par le contrôleur principal.
## Applique des modifications de satisfaction basées sur le type de changement (couleur, meuble placé/retiré) 
## et la pertinence du changement pour la pièce actuelle (`room_index`).
## @param change_type: String Type de changement survenu ("color_changed", "furniture_placed", "furniture_removed").
## @param data: Variant Données associées au changement (ex: Color ou String de nom de meuble).
## @tags environment, events, core
func _on_environment_changed(change_type, data):
	if player_controller.current_room != room_index:
		return
	match change_type:
		"color_changed":
			var points = 0
			match room_index:
				0: # SALON (Confort & Vie sociale)
					match data:
						Color.DARK_ORANGE: points = 18  # Effet feu de cheminée
						Color.DARK_GREEN:  points = 13   # Rappelle la nature (rare au pôle sud)
						Color.DARK_RED:    points = -2  # Un peu trop agressif
						Color.DARK_GRAY:   points = -8  # Triste
						Color.DIM_GRAY:    points = -12 # Déprimant
						Color.WHITE_SMOKE: points = -15 # Trop froid/clinique

				1: # SDB (Hygiène & Réveil)
					match data:
						Color.WHITE_SMOKE: points = 15  # Sensation de propre
						Color.DARK_GREEN:  points = 8   # Ambiance "Spa"
						Color.DARK_ORANGE: points = 4   # Agréable le matin
						Color.DIM_GRAY:    points = -4  # On voit mal la saleté
						Color.DARK_GRAY:   points = -6
						Color.DARK_RED:    points = -10 # Inquiétant dans une douche !

				2: # CUISINE (Énergie & Préparation)
					match data:
						Color.DARK_ORANGE: points = 16 # Appétissant
						Color.DARK_GREEN:  points = 12   # Évoque les légumes frais
						Color.WHITE_SMOKE: points = 5   # Pratique pour cuisiner
						Color.DARK_RED:    points = -5  
						Color.DIM_GRAY:    points = -8  # Donne une impression de nourriture périmée
						Color.DARK_GRAY:   points = -10

				3: # CHAMBRE (Repos & Rythme Circadien)
					match data:
						Color.DARK_RED:    points = 16  # Aide à l'endormissement (pas de lumière bleue)
						Color.DARK_ORANGE: points = 12  # Chaleureux
						Color.DARK_GREEN:  points = 8   # Apaisant
						Color.DARK_GRAY:   points = -6  # Lugubre
						Color.DIM_GRAY:    points = -10
						Color.WHITE_SMOKE: points = -20 # Horrible (bloque le sommeil au pôle)

				4: # LABO (Concentration & Précision)
					match data:
						Color.WHITE_SMOKE: points = 18  # Idéal pour voir les échantillons
						Color.DARK_GREEN:  points = 7   # Calme les nerfs durant les calculs
						Color.DARK_GRAY:   points = 2   # Neutre
						Color.DIM_GRAY:    points = -6
						Color.DARK_ORANGE: points = -11  # Trop chaleureux, on s'endort
						Color.DARK_RED:    points = -16 # Fatigue visuelle intense

				5: # STOCKAGE (Logistique & Sécurité)
					match data:
						Color.DARK_RED:    points = 10  # Code couleur sécurité/nuit
						Color.DIM_GRAY:    points = 6   # Utilitaire
						Color.DARK_GRAY:   points = 4   # Utilitaire
						Color.WHITE_SMOKE: points = 2   # Pratique mais énergivore
						Color.DARK_GREEN:  points = -5  # Difficile de distinguer les étiquettes
						Color.DARK_ORANGE: points = -8  # On dirait qu'il y a un début d'incendie

			change_satisfaction(points)

		"furniture_placed":
			# Gestion de l'ajout d'un meuble
			match data:
				"bunk_bed":
					# Lit superposé
					if room_index == 3: # Chambre
						nblits += 1
						# Bonus tant qu'on a moins de 4 lits
						if nblits < 4:
							change_satisfaction(15)
						else:
							# Trop de lits dans la chambre
							change_satisfaction(-15)
					else:
						# Lit placé dans une mauvaise pièce
						change_satisfaction(-15)

				"closet":
					# Placard
					nb_closet += 1
					# Bonus jusqu'à 3 placards
					if nb_closet < 4:
						change_satisfaction(8)
					else:
						# Trop de placards
						change_satisfaction(-8)

				"gym":
					# Équipement de sport
					nb_gym += 1
					# Bonus uniquement si c'est le premier gym et dans la bonne pièce
					if room_index == 5 && nb_gym == 1:
						change_satisfaction(25)
					else:
						# Mauvaise pièce ou trop d'équipements
						change_satisfaction(-25)

				"wheel_chair", "chair":
					# Chaises et fauteuils roulants
					nb_chair += 1
					# Bonus tant qu'il n'y a pas trop de chaises
					if nb_chair < 15:
						change_satisfaction(2)
					# Malus si surcharge de chaises
					if nb_chair >= 25:
						change_satisfaction(-2)
						# Entre 15 et 25 : neutre

				"table":
					# Tables
					nb_table += 1
					# Tables acceptées seulement dans certaines pièces
					if room_index == 0 || room_index == 2:
						if nb_table < 3:
							change_satisfaction(4)
						else:
							# Trop de tables
							change_satisfaction(-4)
					else:
						# Table dans une mauvaise pièce
						change_satisfaction(-4)

				"sofa":
					# Canapé
					nb_sofa += 1
					# Bonus uniquement pour le premier canapé dans le salon
					if room_index == 0 && nb_sofa == 1:
						change_satisfaction(15)
					else:
						# Canapé en trop ou mal placé
						change_satisfaction(-20)

				"washing_machine":
					# Machine à laver
					nb_washing += 1
					# Bonus dans la buanderie tant qu'il n'y en a pas trop
					if room_index == 1 && nb_washing < 4:
						change_satisfaction(9)
					else:
						change_satisfaction(-9)

				"pc_setup":
					# Poste informatique
					nb_pc += 1
					# Accepté dans certaines pièces et en quantité limitée
					if (room_index == 3 || room_index == 5 || room_index == 4) && nb_pc < 6:
						change_satisfaction(10)
					else:
						change_satisfaction(-10)

				"sink":
					# Évier
					nb_sink += 1
					# Bonus dans salle de bain ou cuisine, quantité limitée
					if (room_index == 1 || room_index == 2) && nb_sink < 3:
						change_satisfaction(7)
					else:
						change_satisfaction(-7)

				"toilet":
					# Toilettes
					nb_toilet += 1
					# Bonus uniquement dans la salle de bain et en nombre raisonnable
					if room_index == 1 && nb_toilet < 4:
						change_satisfaction(15)
					else:
						change_satisfaction(-15)

				"shower":
					# Douche
					nb_shower += 1
					# Bonus dans la salle de bain, limité à 2
					if room_index == 1 && nb_shower < 3:
						change_satisfaction(13)
					else:
						change_satisfaction(-13)

		"furniture_removed": ## Lors de la suppression d'un meuble
			match data:
				"bunk_bed":
					# Retrait d'un lit superposé
					if player_controller.current_room == 3:
						nblits -= 1
						# Retirer un lit en trop redonne un bonus
						if nblits >= 3:
							change_satisfaction(15)
						else:
							change_satisfaction(-15)
					else:
						# Retirer un lit mal placé est positif
						change_satisfaction(15)

				"gym":
					# Retrait d'un équipement de sport
					nb_gym -= 1
					# Retirer le seul gym de la bonne pièce est négatif
					if room_index == 5 && nb_gym == 0:
						change_satisfaction(-25)
					else:
						change_satisfaction(25)

				"closet":
					# Retrait d'un placard
					nb_closet -= 1
					if nb_closet >= 3:
						change_satisfaction(8)
					else:
						change_satisfaction(-8)

				"wheel_chair", "chair":
					# Retrait d'une chaise
					nb_chair -= 1
					# Passer sous le seuil utile est négatif
					if nb_chair < 14:
						change_satisfaction(-2)
					# Retirer une chaise en surcharge est positif
					if nb_chair >= 25:
						change_satisfaction(2)

				"table":
					# Retrait d'une table
					nb_table -= 1
					if room_index == 0 || room_index == 2:
						if nb_table >= 2:
							change_satisfaction(4)
						else:
							change_satisfaction(-4)
					else:
						# Retirer une table mal placée est positif
						change_satisfaction(4)

				"sofa":
					# Retrait d'un canapé
					nb_sofa -= 1
					# Retirer un canapé inutile est positif
					if room_index != 0 || nb_sofa > 0:
						change_satisfaction(15)
					else:
						# Supprimer l'unique canapé du salon est négatif
						change_satisfaction(-20)

				"washing_machine":
					# Retrait d'une machine à laver
					nb_washing -= 1
					if room_index != 1 || nb_washing >= 3:
						change_satisfaction(9)
					else:
						change_satisfaction(-9)

				"pc_setup":
					# Retrait d'un PC
					nb_pc -= 1
					# Retirer un PC mal placé ou en surplus est positif
					if room_index == 0 || room_index == 1 || room_index == 2 || nb_pc >= 5:
						change_satisfaction(10)
					else:
						change_satisfaction(-10)

				"sink":
					# Retrait d'un évier
					nb_sink -= 1
					# Bonus si on en a encore assez ou s'il était mal placé
					if ((room_index == 1 || room_index == 2) && nb_sink >= 2) || (room_index != 1 && room_index != 2):
						change_satisfaction(7)
					else:
						change_satisfaction(-7)

				"toilet":
					# Retrait de toilettes
					nb_toilet -= 1
					if (room_index == 1 && nb_toilet >= 3) || room_index != 1:
						change_satisfaction(15)
					else:
						change_satisfaction(-15)

				"shower":
					# Retrait d'une douche
					nb_shower -= 1
					if (room_index == 1 && nb_shower >= 2) || room_index != 1:
						change_satisfaction(13)
					else:
						change_satisfaction(-13)
		"light_intensity_changed":
			var base_satisfaction = light_intensity_satisfaction # On retire l'ancien bonus
			
			if room_index == 1 or room_index == 3 or room_index == 0: # Sommeil / Salle de bain
				if data < 20:
					light_intensity_satisfaction = -10  # impossible de faire quoi que ce soit
				elif data < 50:
					light_intensity_satisfaction = 15  # Idéal dans la chambre etc...
				elif data < 80:
					light_intensity_satisfaction = -25 # Trop lumineux 
				else:
					light_intensity_satisfaction = -35 # Insupportable
			else: # Bureaux / Travail
				if data < 30:
					light_intensity_satisfaction = -50 # Trop sombre (danger dépression)
				elif data < 60:
					light_intensity_satisfaction = 5   # Moyen
				elif data < 90:
					light_intensity_satisfaction = 25  # Optimal pour la concentration
				else:
					light_intensity_satisfaction = 15  # Un peu trop éblouissant
					
			change_satisfaction(light_intensity_satisfaction- base_satisfaction)
		"light_heat_changed":
			var base_satisfaction = light_heat_satisfaction
			
	
			if room_index == 1 or room_index == 3 or room_index == 0: # Chambres / SDB (Détente)
				if data < 40:
					light_heat_satisfaction = 25 # Lumière rouge = relaxation
				elif data < 60:
					light_heat_satisfaction = 5   # Neutre
				else:
					light_heat_satisfaction = -30  # Lumière froide : insomnie
					
			else: # Bureaux / Laboratoires (Travail)
				if data < 30:
					light_heat_satisfaction = -20  # Lumière trop orange : donne envie de dormir au travail 
				elif data < 60:
					light_heat_satisfaction = 0   # Neutre
				else:
					light_heat_satisfaction = 25 # Lumière froide : booste la productivité
			
			change_satisfaction(light_heat_satisfaction - base_satisfaction)
			
			
	player_controller.room_satisfaction[room_index] = satisfaction

## @func_doc
## @description Crée et affiche un émoji 3D animé au-dessus du PNJ.
## L'émoji s'anime (apparition, déplacement) et disparaît automatiquement après un court délai.
## @param emoji_text: String Le caractère émoji à afficher (ex: "😊", "🤬").
## @param npc: NavigationNPC Référence au PNJ pour ajouter le Label3D comme enfant.
## @tags visuals, animation
func show_animated_emoji(emoji_text: String, npc: NavigationNPC):
	
	# CHARGEMENT DE L'ASSET DE POLICE ET CRÉATION DU LABEL
	var font = load("res://Import/Fonts/NotoColorEmoji-Regular.ttf")
	
	var label = Label3D.new()
	label.text = emoji_text
	label.modulate = Color(1, 1, 1, 1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 3.0, 0)
	label.scale = Vector3(0, 0, 0)
	label.font_size = 128
	
	if font:
		label.font = font
	else:
		push_warning("Police NotoColorEmoji-Regular.ttf introuvable")
	
	current_emoji = label
	npc.add_child(label)

	# LOGIQUE D'ANIMATION (APPEAR / MOVE / FADE)
	var tween = label.create_tween()
	tween.set_parallel(true)
	
	# Animation d'apparition et de déplacement vertical
	tween.tween_property(label, "scale", Vector3(1.3, 1.3, 1.3), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", Vector3(0, 4.0, 0), 0.5)
	
	# Animation de disparition (fade out) après un délai
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(2.0)
	
	# Connexion de la fonction de nettoyage à la fin de l'animation
	tween.finished.connect(_on_emoji_animation_finished.bind(label))


## @func_doc
## @description Fonction de rappel (callback) appelée lorsque l'animation de l'émoji est terminée.
## Nettoie et libère le nœud Label3D de l'émoji.
## @param emoji_label: Label3D Le nœud Label3D qui vient de terminer son animation.
## @tags cleanup, animation
func _on_emoji_animation_finished(emoji_label: Label3D):
	# Nettoie la référence si c'est l'emoji actuel
	if current_emoji == emoji_label:
		current_emoji = null
	emoji_label.queue_free()

## @func_doc
## @description Supprime immédiatement l'émoji actuellement affiché.
## @tags cleanup
func clear_emoji():
	if current_emoji and is_instance_valid(current_emoji):
		current_emoji.queue_free()
		current_emoji = null

## @var_doc
## @description Compteur utilisé pour détecter si le PNJ est bloqué dans son mouvement.
## @tags navigation, state
var stuck_timer: float = 0.0

## @var_doc
## @description Seuil de temps (en secondes) au-delà duquel le PNJ est considéré comme bloqué.
## @tags config, navigation
var STUCK_THRESHOLD: float = 1.0

## @var_doc
## @description Vitesse de déplacement du PNJ.
## @tags config, movement
var SPEED: float = 2.0

## @var_doc
## @description État booléen indiquant si le PNJ est autorisé à se déplacer.
## @tags state, movement
var Move: bool = true

## @var_doc
## @description État booléen indiquant si le PNJ attend une période aléatoire après avoir atteint une destination.
## @tags state, navigation
var waiting := false

## @func_doc
## @description Fonction d'initialisation post-instanciation pour configurer le PNJ.
## Définit le nom, l'émoji, et tente de charger et d'instancier le modèle 3D spécifié.
## @param NPC_name: String Le nom du PNJ.
## @param model_name: String Le nom du fichier de modèle 3D (ex: "Nils.fbx") à charger.
## @param em: String L'émoji de base du PNJ.
## @return void
## @tags init, config, model
func setup(NPC_name: String = "DefaultName", model_name: String = "Nils", em: String = emoji) -> void:
	self.npc_name = NPC_name
	
	self.emoji = em
	
	# LOGIQUE DE CHARGEMENT DYNAMIQUE DU MODÈLE 3D
	var path = "res://Import/Models/NPC/%s.fbx" % model_name
	if ResourceLoader.exists(path):
		var scene = load(path)
		if scene is PackedScene:
			model = scene.instantiate()
			add_child(model)
		else:
			push_warning("Le fichier %s n'est pas une scène valide." % path)
	else:
		push_warning("Modèle %s introuvable dans Import/Models/NPC/" % model_name)
	

## @func_doc
## @description Gère le mouvement du PNJ basé sur l'agent de navigation.
## Inclut la détection d'arrivée à destination, la rotation du modèle, et la détection si le PNJ est bloqué.
## @param delta: float Temps écoulé depuis la dernière frame.
## @return void
## @tags core, physics, navigation, movement
func _physics_process(delta: float) -> void:
	if not Move or waiting:
		return
	
	if navigation_agent_3d.is_navigation_finished():
		waiting = true
		velocity = Vector3.ZERO
		# Attente aléatoire après l'arrivée
		await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
		waiting = false
		_set_new_random_destination()
		return

	# Logique de mouvement
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var distance = local_destination.length()

	if distance < 0.3:
		velocity = Vector3.ZERO
		return

	var direction = local_destination.normalized()
	velocity = direction * SPEED
	move_and_slide()

	# Rotation pour faire face à la direction du mouvement
	if velocity.length() > 0.05:
		var target_rotation = atan2(direction.x, direction.z)
		var new_rotation = lerp_angle(rotation.y, target_rotation, 5.0 * delta)
		rotation.y = new_rotation

	# Détection de blocage (vitesse faible pendant trop longtemps)
	if velocity.length() < 0.05:
		stuck_timer += delta
		if stuck_timer >= STUCK_THRESHOLD:
			_set_new_random_destination()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0

## @func_doc
## @description Définit une nouvelle destination de navigation aléatoire dans un rayon de [-5, 5] sur les axes XZ.
## @return void
## @tags navigation, movement
func _set_new_random_destination() -> void:
	Move = true
	SPEED = 2.0
	var random_position := Vector3(
		randf_range(-5.0, 5.0),
		0,
		randf_range(-5.0, 5.0)
	)
	navigation_agent_3d.set_target_position(random_position)

## @func_doc
## @description Arrête le mouvement du PNJ en réinitialisant sa vitesse et en désactivant le mouvement.
## @return void
## @tags movement, navigation
func _set_destination_null() -> void:
	SPEED = 0.0
	Move = false

## @func_doc
## @description Réactive le mouvement et définit la vitesse à la valeur par défaut (2.0).
## @return void
## @tags movement
func speed_boost() -> void:
	SPEED = 2.0
	Move = true
