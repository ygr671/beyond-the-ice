extends Node3D

@export var npc_scene: PackedScene = preload("res://npc/navigation_npc.tscn")

func _ready() -> void:
	for i in range(4):
		
		var npc = npc_scene.instantiate() as NavigationNPC
		
		var random_x = randf_range(0.0, 5.0)
		var random_z = randf_range(0.0, 5.0)
		# Position aléatoire dans la salle lors de l'apparition
		npc.global_position = global_position + Vector3(random_x, 0, random_z)
		add_child(npc)
