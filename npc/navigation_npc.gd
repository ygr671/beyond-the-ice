extends CharacterBody3D

class_name NavigationNPC 


@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var model = $MeshInstance3D

@export var npc_name: String = "NPC"
@export var emoji: String = "😁"


# Référence à l'emoji actuel
var current_emoji: Label3D = null
var satisfaction = 50
var real_satisfaction = satisfaction
var room_index: int = 0
var nblits = 1
var emoji_timer: Timer



func _ready():
	player_controller.connect("environment_changed", Callable(self, "_on_environment_changed"))
	# === Timer pour lancer emoji automatiquement ===
	emoji_timer = Timer.new()
	emoji_timer.wait_time = 5.0
	emoji_timer.autostart = true
	emoji_timer.one_shot = false
	add_child(emoji_timer)
	emoji_timer.timeout.connect(_on_emoji_timer_timeout)
	

func _on_emoji_timer_timeout():
	var current_emoji_text = emoji
	if satisfaction >= 80:
		current_emoji_text = "😇"
	elif satisfaction >= 60:
		current_emoji_text = "😊"
	elif satisfaction >= 40:
		current_emoji_text = "😐"
	elif satisfaction >=20:
		current_emoji_text = "😟"
	else:
		current_emoji_text = "🤬"
	show_animated_emoji(current_emoji_text, self)

func change_satisfaction(valeur: int):
	real_satisfaction += valeur
	if real_satisfaction >= 0 && real_satisfaction <= 100:
		satisfaction = real_satisfaction
	elif real_satisfaction <= 0:
		satisfaction = 0
	else:
		satisfaction = 100
	
	

func _on_environment_changed(change_type, data):
	if player_controller.current_room != room_index:
		return
	print("room index  ", room_index)
	match change_type:
		"color_changed":
			match data:   # data = Color
				Color.ORANGE:
					change_satisfaction(10)
				Color.RED:
					change_satisfaction(-10)
				Color.GRAY:
					change_satisfaction(-8)
				Color.WHITE:
					change_satisfaction(-15)
				Color.BLACK:
					change_satisfaction(-8)
				Color.GREEN:
					change_satisfaction(10)

		"furniture_placed":
			match data:
				"lit_superpose":
					if player_controller.current_room == 3: #salle chambre
						nblits += 1
						print("nbr de lits " , nblits)
						if nblits == 2:
							print("assez de lit")
							change_satisfaction(15)
						else:
							change_satisfaction(-15)
					else:
						change_satisfaction(-15)
					print("satisfaction : ", satisfaction)	
		"furniture_removed":
			match data:
				"lit_superpose":
					if player_controller.current_room == 3:
						
						nblits -= 1
						if nblits >= 2:
							change_satisfaction(15)
						else:
							change_satisfaction(-15) 
					else:
						change_satisfaction(15)
					print("lit retiré")
					print("satisfaction : ", satisfaction)


func show_animated_emoji(emoji_text: String, npc: NavigationNPC):
	# Charge la font pour l'emoji animé
	var font = load("res://Import/Fonts/NotoColorEmoji-Regular.ttf")
	
	# Crée le nouvel emoji
	var label = Label3D.new()
	label.text = emoji_text
	label.modulate = Color(1, 1, 1, 1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 2.5, 0)
	label.scale = Vector3(0, 0, 0)
	label.font_size = 128
	
	# Assigner la font
	if font:
		label.font = font
	else:
		push_warning("Police NotoColorEmoji-Regular.ttf introuvable")
	
	# Stocke la référence
	current_emoji = label
	npc.add_child(label)

	var tween = label.create_tween()
	tween.set_parallel(true)
	
	# Animation d'apparition
	tween.tween_property(label, "scale", Vector3(1.3, 1.3, 1.3), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", Vector3(0, 3.0, 0), 0.5)
	
	# Disparition après 3 secondes
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(3.0)
	
	tween.finished.connect(_on_emoji_animation_finished.bind(label))

func _on_emoji_animation_finished(emoji_label: Label3D):
	# Nettoie la référence si c'est l'emoji actuel
	if current_emoji == emoji_label:
		current_emoji = null
	emoji_label.queue_free()

func clear_emoji():
	if current_emoji and is_instance_valid(current_emoji):
		current_emoji.queue_free()
		current_emoji = null

var stuck_timer: float = 0.0
var STUCK_THRESHOLD: float = 1.0
var SPEED: float = 2.0
var Move: bool = true
var waiting := false

func setup(NPC_name: String = "DefaultName", model_name: String = "Nils", em: String = emoji) -> void:
	self.npc_name = NPC_name
	self.emoji = em
	
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
	

func _physics_process(delta: float) -> void:
	if not Move or waiting:
		return
	
	if navigation_agent_3d.is_navigation_finished():
		waiting = true
		velocity = Vector3.ZERO
		await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
		waiting = false
		_set_new_random_destination()
		return

	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var distance = local_destination.length()

	if distance < 0.3:
		velocity = Vector3.ZERO
		return

	var direction = local_destination.normalized()
	velocity = direction * SPEED
	move_and_slide()

	if velocity.length() > 0.05:
		var target_rotation = atan2(direction.x, direction.z)
		var new_rotation = lerp_angle(rotation.y, target_rotation, 5.0 * delta)
		rotation.y = new_rotation

	if velocity.length() < 0.05:
		stuck_timer += delta
		if stuck_timer >= STUCK_THRESHOLD:
			_set_new_random_destination()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0

func _set_new_random_destination() -> void:
	Move = true
	SPEED = 2.0
	var random_position := Vector3(
		randf_range(-5.0, 5.0),
		0,
		randf_range(-5.0, 5.0)
	)
	navigation_agent_3d.set_target_position(random_position)

func _set_destination_null() -> void:
	SPEED = 0.0
	Move = false

func speed_boost() -> void:
	SPEED = 2.0
	Move = true
