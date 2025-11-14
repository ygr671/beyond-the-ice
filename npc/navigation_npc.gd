extends CharacterBody3D

class_name NavigationNPC 
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var model = $MeshInstance3D

@export var npc_name: String = "NPC"
@export var dialogue: String = "Bonjour !"
@export var emoji: String = "😁"

@onready var label := $Sprite3D/SubViewport/Label




func _display() -> String:
	return "Je m'appelle " + npc_name + " " + dialogue

var stuck_timer: float = 0.0
var STUCK_THRESHOLD: float = 1.0
var SPEED: float = 2.0
var Move: bool = true
var waiting := false


func setup(name: String = "DefaultName", dialogue_text: String = "Bonjour !", model_name: String = "Nils", em: String = emoji) -> void:
	self.npc_name = name
	self.dialogue = dialogue_text
	self.label.text = em
	var path = "res://Import/Models/%s.fbx" % model_name
	if ResourceLoader.exists(path):
		var scene = load(path)
		if scene is PackedScene:
			model = scene.instantiate()
			add_child(model)
		else:
			push_warning("Le fichier %s n'est pas une scène valide." % path)
	else:
		push_warning("Modèle %s introuvable dans Import/Models/" % model_name)
	print("[DEBUG] NPC setup : ", name, " - ", dialogue_text, " (modèle : ", model_name, ")")


# Mouvement
func _physics_process(delta: float) -> void:
	if not Move or waiting:
		return
	
	# si la navigation est terminée il attend un peu avant de repartir
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

	# si trop proche du point, il ne bouge plus (évite tremblement et bloquage)
	if distance < 0.3:
		velocity = Vector3.ZERO
		return

	var direction = local_destination.normalized()
	velocity = direction * SPEED
	move_and_slide()

	# changement de direction fluide quand il se déplace
	if velocity.length() > 0.05:
		var target_rotation = atan2(direction.x, direction.z)
		var new_rotation = lerp_angle(rotation.y, target_rotation, 5.0 * delta)
		rotation.y = new_rotation

	# nouvelle destination lors d'un bloquage prolongé
	if velocity.length() < 0.05:
		stuck_timer += delta
		if stuck_timer >= STUCK_THRESHOLD:
			_set_new_random_destination()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0



# Destinations
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
