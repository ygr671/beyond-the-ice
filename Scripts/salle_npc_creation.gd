extends Node3D

@export var npc_scene: PackedScene = preload("res://npc/navigation_npc.tscn")
@onready var right_wall = $"Mur_droit/MeshInstance3D"
@onready var left_wall = $"Mur_gauche/MeshInstance3D"

var already_changed_color = false

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	var nb_npc = rng.randi_range(1, 4)
	for i in range(nb_npc):
		var npc = npc_scene.instantiate() as NavigationNPC
		npc.room_index = get_parent().get_index()
		add_child(npc)
		npc.setup("Nils", "Nils", "😁")
		
		
		var random_x = randf_range(0.0, 5.0)
		var random_z = randf_range(0.0, 5.0)
		# Position aléatoire dans la salle lors de l'apparition
		npc.global_position = global_position + Vector3(random_x, 0, random_z)
	player_controller.connect("environment_changed", Callable(self, "_on_environment_changed"))

func set_wall_color(material_ressource: StandardMaterial3D, color_name: String):
	var targets = [right_wall, left_wall]
	for target in targets:
		if is_instance_id_valid(target):
			target.set_surface_override_material(0, material_ressource)
	player_controller.emit_signal("environment_changed", "color_changed", color_name)
	
func _on_environment_changed(change_type, data):
	var room_index = get_parent().get_index();
	if room_index != player_controller.current_room or already_changed_color:
		return
	already_changed_color = true
	var targets = [right_wall, left_wall]
	match change_type:
		"color_changed":
			for wall_mesh in targets:
				if wall_mesh.mesh:
					var unique_mesh = wall_mesh.mesh.duplicate(true)
					wall_mesh.mesh = unique_mesh
				
				var unique_mat = StandardMaterial3D.new()
				
				if typeof(data) == TYPE_COLOR:
					unique_mat.albedo_color = data
				else:
					unique_mat.albedo_color = Color.MAGENTA
				
				wall_mesh.material_override = unique_mat
					
