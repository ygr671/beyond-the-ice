## @class_doc
## @description Gestionnaire de couleur pour un objet 3D (mur ou surface).
## Ce script permet de changer le material de la mesh et d'emettre un signal
## au PlayerController pour notifier un changement d'environnement.
## @tags 3d, material, environment, signaling

extends Node3D

# --- References de Noeuds et Ressources ---

## @onready_doc
## @description Reference au MeshInstance3D dont le material de surface sera modifie.
## @tags nodes, mesh
@onready var wall_mesh = $MeshInstance3D

## @onready_doc
## @description Material Orange precharge pour le mur.
## @tags resources, material
@onready var orange = preload("res://materials/Wall/Orange.tres")

## @onready_doc
## @description Material Rouge precharge pour le mur.
## @tags resources, material
@onready var red = preload("res://materials/Wall/Red.tres")

## @onready_doc
## @description Material Gris precharge pour le mur.
## @tags resources, material
@onready var gray = preload("res://materials/Wall/Gray.tres")

## @onready_doc
## @description Material Blanc precharge pour le mur.
## @tags resources, material
@onready var white = preload("res://materials/Wall/White.tres")

## @onready_doc
## @description Material Noir precharge pour le mur.
## @tags resources, material
@onready var black = preload("res://materials/Wall/Black.tres")

## @onready_doc
## @description Material Vert precharge pour le mur.
## @tags resources, material
@onready var green = preload("res://materials/Wall/Green.tres")

## @func_doc
## @description Applique un nouveau material a la mesh du mur et emet un signal
## pour indiquer un changement de couleur d'environnement.
## @param material_ressource: StandardMaterial3D Le nouveau material a appliquer.
## @param color_name: Color La valeur de la couleur a transmettre dans le signal.
## @tags core, material, signaling
func set_color(material_ressource: StandardMaterial3D, color_name: Color):
	# Applique le material au premier (et unique) index de surface (0)
	wall_mesh.set_surface_override_material(0, material_ressource)
	
	# Emission du signal pour informer le reste du jeu (PNJ, systemes d'humeur, etc.)
	player_controller.emit_signal("environment_changed", "color_changed", color_name)
