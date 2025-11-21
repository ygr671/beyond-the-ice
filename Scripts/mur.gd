extends Node3D
#On charge chaque variente de couleur
@onready var wall_mesh = $MeshInstance3D
@onready var orange = preload("res://materials/Wall/Orange.tres")
@onready var red = preload("res://materials/Wall/Red.tres")
@onready var gray = preload("res://materials/Wall/Gray.tres")
@onready var white = preload("res://materials/Wall/White.tres")
@onready var black = preload("res://materials/Wall/Black.tres")
@onready var green = preload("res://materials/Wall/Green.tres")



func set_color(material_ressource: StandardMaterial3D, color_name: String):
	wall_mesh.set_surface_override_material(0, material_ressource)
	# émission du signal
	player_controller.emit_signal("environment_changed", "color_changed", color_name)
