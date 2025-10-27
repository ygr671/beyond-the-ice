extends CharacterBody3D

class_name NavigationNPC 
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var model = $Nils

@export var npc_name: String = "NPC"
@export var dialogue: String = "Bonjour !"

<<<<<<< HEAD
func _display() ->String:
	return "Je m'appelle " + npc_name +" " + dialogue
=======


func _display() -> String:
	return "Je m'appelle " + npc_name + " " + dialogue
>>>>>>> 2c8152b2ce7b64e7e899818edef9b5a9edd78ab6

var stuck_timer: float = 0.0
var STUCK_THRESHOLD: float = 0.0
var SPEED: float = 2.0
var Move: bool = true




func _physics_process(delta: float) -> void:
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	
	# Vérifie si le NPC est bloqué
	if velocity.length() < 0.01:
		stuck_timer += delta
		if stuck_timer >= STUCK_THRESHOLD and Move == true:
			_set_new_random_destination()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0  # réinitialise si le NPC bouge
		var target_ratotion = atan2(direction.x, direction.z)
		var current_rotation = model.rotation.y
		var new_rotation = lerp_angle(current_rotation, target_ratotion, 5.0 * delta)
		model.rotation = Vector3(0, new_rotation, 0)

func _set_new_random_destination() -> void:
	Move = true
	SPEED = 2.0
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-5.0, 5.0)
	random_position.z = randf_range(-5.0, 5.0)
	navigation_agent_3d.set_target_position(random_position)

func _set_destination_null() -> void:
	SPEED = 0.0
	Move  = false

func speed_boost() -> void:
	SPEED = 2.0
	Move  = true
