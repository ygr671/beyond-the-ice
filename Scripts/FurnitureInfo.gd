class_name FurnitureInfo
extends Resource

# La scène du meuble
@export var scene: PackedScene

# Nom du meuble
@export var name: String

# Quantité disponible au départ
@export var stock: int = 0
@export var restock_count: int = 0

# Image pour l'inventaire / menu
@export var image: Texture2D

# Valeur du bonus de base du meuble
@export var base_value: int = 0

# Bonus/Malus par salle (clé = index salle)
@export var room_bonuses: Dictionary = {
	0: 1,
	1: 1,
	2: 1,
	3: 1,
	4: 1,
	5: 1
}

# Nombre maximum de ce meuble par salle avant d'appliquer un malus
@export var maximum_placed: int = 1

# Retourne le bonus (ou malus le cas échéant) pour une salle donnée
func get_bonus(room_index: int, placed_count: int) -> int:
	return room_bonuses.get(room_index, placed_count)
