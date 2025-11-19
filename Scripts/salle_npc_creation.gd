extends Node3D

@export var npc_scene: PackedScene = preload("res://npc/navigation_npc.tscn")

func _ready() -> void:
	for i in range(4):
		
		var npc = npc_scene.instantiate() as NavigationNPC
		npc.room_index = get_parent().get_index()
		add_child(npc)  # Important : onready se déclenche maintenant
		npc.setup("Nils", "Bienvenue à la base Concordia !", "Nils", "😁")
		
		
		var random_x = randf_range(0.0, 5.0)
		var random_z = randf_range(0.0, 5.0)
		# Position aléatoire dans la salle lors de l'apparition
		npc.global_position = global_position + Vector3(random_x, 0, random_z)
