## @class_doc
## @description Gestionnaire d'interface utilisateur (UI) spécifique a la pièce de Stockage.
## Ce script herite des fonctionnalites de base de la selection d'objets (ui_objects_selection.gd)
## et applique des filtres pour n'afficher que les meubles relatifs au stockage
## (etageres, placards, equipements de nettoyage, etc.) dans le catalogue ou l'inventaire.
## @tags ui, inventory, room_specific, inheritance

extends "res://Scripts/ui_objects_selection.gd"
