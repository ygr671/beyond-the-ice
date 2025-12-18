## @class_doc
## @description Gere les donnees de dialogue et le positionnement de l'interface pour Knuckles.
## Contient une liste de repliques aleatoires et les parametres d'affichage de la bulle de texte.
## @tags npc, dialog, data
extends Node3D


## @export_doc
## @description Liste des lignes de dialogue que le personnage peut prononcer.
## Ces chaines sont selectionnees de maniere aleatoire lors des interactions.
## @tags dialog, config
@export var dialog_lines: Array[String] = [
	"Do you know da way?",
	"Spit on da fake queen!",
	"Follow me bruddah!",
	"Gotta go fast!",
	"You're too slow!",
	"Where is da Emerald?",
	"I never chuckle, I'd rather flex my muscles.",
	"Sonic, help me!",
	"Live and learn!",
	"Chaos Control!",
	"I found the computer room!",
	"Get a load of this!",
	"Snooping as usual, I see!",
	"Look at all these Eggman's robots...",
	"The power of the Chaos Emeralds is mine!",
	"Shadow, is that you?",
	"Oh no!",
	"Chili dogs are da way!",
	"Welcome to Green Hill Zone!",
	"Don't touch my Master Emerald!",
	"I'm the coolest!",
	"It's no use!",
	"Find da computer room, bruddah!",
	"Everything is better with rings.",
	"Is this a fake emerald?",
	"You'll regret this, Eggman!",
	"Step it up!",
	"Long time no see!",
	"I will show you da way of da warrior.",
	"A ghost?! Nooooo!"
]

## @export_doc
## @description Decalage 3D pour positionner la bulle de texte au-dessus du personnage.
## @tags ui, transform, config
@export var textbox_offset := Vector3(0, 2.5, 0)
