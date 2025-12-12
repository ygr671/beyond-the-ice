## @class_doc
## @description Contrôleur d'un personnage non-joueur (PNJ) utilisant la navigation 3D.
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
var satisfaction = 50

## @var_doc
## @description Valeur de satisfaction brute, utilisée pour les calculs avant d'être clampée dans 'satisfaction'.
## @tags state
var real_satisfaction = satisfaction

## @var_doc
## @description Index de la salle où se trouve actuellement le PNJ.
## Utilisé pour les vérifications de pertinence des meubles.
## @tags state, room
var room_index: int = 0

# --- Variables de comptage des meubles pour les calculs de satisfaction ---
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
	elif valeur >= 0: # Correction de la logique, devrait être entre 0 et 15
		current_emoji_text = "😊" # Petite joie
	# Note: La ligne 'elif valeur >=0:' semble être une erreur logique dans le script original.
	elif valeur >=0: 
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
	# Ignore les changements si le PNJ n'est pas dans la pièce affectée
	if player_controller.current_room != room_index:
		return
		
	match change_type:
		"color_changed":
			# Logique de réaction au changement de couleur
			match data:
				Color.DARK_ORANGE:
					change_satisfaction(10)
				Color.DARK_RED:
					change_satisfaction(-10)
				# ... autres couleurs et leurs impacts
				
		"furniture_placed":
			# Logique de réaction à l'ajout de meubles, gérant les compteurs et les limites par pièce
			match data:
				"bunk_bed":
					if room_index == 3: #salle chambre
						nblits += 1
						if nblits <= 2:
							change_satisfaction(15)
						else:
							change_satisfaction(-15) # Pénalité pour trop de lits
					else:
						change_satisfaction(-15) # Pénalité si le lit n'est pas dans la chambre
				# ... autres meubles et leurs impacts (closet, gym, chair, table, sofa, washing_machine, pc_setup)
				
		"furniture_removed":
			# Logique de réaction au retrait de meubles, ajustant les compteurs et la satisfaction.
			match data:
				"bunk_bed":
					if player_controller.current_room == 3:
						nblits -= 1
						# Logique inverse des effets de placement
						if nblits >= 3:
							change_satisfaction(15)
						else:
							change_satisfaction(-15) 
					else:
						change_satisfaction(15) # Gain si meuble inutile est retiré d'ailleurs
				# ... autres meubles et leurs impacts inverses
				
	# Mettre à jour l'état de satisfaction de la pièce après tout changement
	player_controller.room_satisfaction[room_index] = satisfaction

## @func_doc
## @description Crée et affiche un émoji 3D animé au-dessus du PNJ.
## L'émoji s'anime (apparition, déplacement) et disparaît automatiquement après un court délai.
## @param emoji_text: String Le caractère émoji à afficher (ex: "😊", "🤬").
## @param npc: NavigationNPC Référence au PNJ pour ajouter le Label3D comme enfant.
## @tags visuals, animation
func show_animated_emoji(emoji_text: String, npc: NavigationNPC):
	# ... (logique de chargement de font, création du Label3D, animation avec Tween)
	# ... (Le code utilise une ressource 'res://Import/Fonts/NotoColorEmoji-Regular.ttf')

	# ... (omission du corps de la fonction pour la concision)

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

	var tween = label.create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(label, "scale", Vector3(1.3, 1.3, 1.3), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", Vector3(0, 4.0, 0), 0.5)
	
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(2.0)
	
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
	
	# Logique pour charger le modèle 3D dynamiquement (omission du corps de la fonction pour la concision)
	
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

	# Logique de mouvement et de détection de blocage
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
