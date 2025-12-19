## @class_doc
## @description Contrôleur global de l'état du jeu (Singleton/Autoload).
## Gère le cycle Jour/Nuit, la météo, l'inventaire des meubles, la satisfaction
## globale par pièce, et sert de point central pour l'émission des signaux
## de changements d'environnement vers les PNJ et autres systèmes.
## @tags core, singleton, global_state, inventory

extends Node

## @var_doc
## @description Index de la pièce actuellement visualisée par le joueur (0 à 5).
## @tags state, scene
var current_room: int = 0

## @var_doc
## @description Etat booléen indiquant si le jeu est en période Jour (true) ou Nuit (false).
## Impacte le travail (charging_bar.gd) et la satisfaction des PNJ.
## @tags state, time
var is_day: bool = true

## @var_doc
## @description Etat booléen indiquant la qualité de la météo.
## True = Bonne météo, False = Mauvaise météo. Impacte les probabilités de succès des commandes.
## @tags state, weather
var weather: bool = true

## @var_doc
## @description Liste des ressources de type FurnitureInfo gérant l'inventaire des meubles.
## @tags data, inventory
var furniture_list: Array[FurnitureInfo] = []

## @var_doc
## @description Tableau stockant le niveau de satisfaction moyen (0-100) pour chaque pièce.
## L'index correspond à l'index de la pièce.
## @tags state, core
var room_satisfaction: Array[int] = []

var chrono: float = 0.0

## @signal_doc
## @description Émis lorsqu'un changement susceptible d'affecter les PNJ ou l'environnement se produit.
## Connecté notamment par NavigationNPC pour la réaction à la couleur des murs ou aux meubles.
## @param change_type: String Type de changement survenu ("color_changed", "furniture_placed", etc.).
## @param data: Variant Données spécifiques au changement (Couleur, Nom de meuble, etc.).
signal environment_changed(change_type, data)

## @signal_doc
## @description Émis lorsque le joueur lance une commande de meuble.
## Connecté par charging_bar.gd pour démarrer la barre de progression.
## @param index: int Index du meuble commandé dans 'furniture_list'.
signal furniture_ordered(index)

## @func_doc
## @description Initialisation du contrôleur.
## Émet les signaux d'initialisation pour les systèmes connectés et initialise le tableau de satisfaction.
## @tags init, core
func _ready():
	# Émet des signaux d'initialisation (bien que les données soient null/non utilisées, cela assure que les systèmes sont connectés)
	emit_signal("environment_changed", "init", null)
	emit_signal("furniture_ordered", "init")
	
	# Redimensionne et initialise la satisfaction de chaque pièce à 50 (neutre)
	room_satisfaction.resize(6)
	room_satisfaction.fill(50)
