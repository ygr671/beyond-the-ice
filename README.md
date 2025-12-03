# Beyond the Ice

🇫🇷  
Beyond the Ice est un jeu éducatif développé avec le moteur Godot dans le cadre d’un projet universitaire.  
Le projet combine un jeu de gestion en environnement polaire avec une plateforme web Laravel permettant d’enregistrer les résultats et le score des joueurs.

🇬🇧  
Beyond the Ice is an educational game developed with the Godot engine as part of a university project.  
The project combines a management game set in a polar environment with a Laravel web platform used to store player results and scores.

## Description

🇫🇷  
Le projet met l’accent sur :  
- la conception logicielle (UML, architecture modulaire)  
- la gestion de projet (PERT, Gantt, découpage en tâches)  
- un gameplay basé sur la gestion d’un espace, l’interaction avec des objets et le comportement de PNJ  
- l’apprentissage et l’utilisation du moteur Godot  
- un accompagnement web via un site Laravel permettant la sauvegarde et la consultation des scores

Le joueur peut modifier la pièce (changer la couleur des murs, ajouter ou retirer des meubles), et les NPC réagissent dynamiquement à ces changements.  
Les actions du joueur influencent la satisfaction des NPC, la progression, et le score final, envoyé vers la plateforme web.

🇬🇧  
The project focuses on:  
- software design (UML, modular architecture)  
- project management (PERT, Gantt, structured tasks)  
- gameplay centered on environment management, object interaction, and NPC behavior  
- learning and using the Godot engine  
- a companion Laravel web platform used to store and view player scores

The player can modify the room (change wall colors, add or remove furniture), and NPCs react dynamically to these changes.  
Player actions affect NPC satisfaction, progression, and the final score, which is uploaded to the web platform.

## Technologies / Stack

🇫🇷 / 🇬🇧  
- Godot Engine (4.x)  
- GDScript  
- Laravel (backend pour les scores)  
- MySQL / SQLite  
- UML diagrams  
- PERT / Gantt  
- Git & GitHub  
- (En cours) Docker pour conteneurisation du jeu + du site web

## Installation & Lancement

### 🇫🇷

1. Clonez le dépôt :  
git clone https://github.com/ygr671/beyond-the-ice  
cd beyond-the-ice

2. Ouvrez le projet dans Godot (version recommandée : 4.5)

3. Lancez le jeu ou exportez-le

4. (Optionnel) Pour la plateforme web Laravel, suivez les instructions du dépôt associé

### 🇬🇧

1. Clone the repository:  
git clone https://github.com/ygr671/beyond-the-ice  
cd beyond-the-ice

2. Open the project with Godot (recommended version: 4.5)

3. Run or export the game

4. (Optional) For the Laravel platform, follow the instructions in its repository

## Fonctionnalités / Features

### 🇫🇷 Implémentées
- Structure complète du projet Godot  
- Architecture des scènes / nodes  
- Système de navigation des NPC  
- Réactions dynamiques des NPC aux actions du joueur  
- Ajout / suppression de meubles en temps réel  
- Changement de la couleur des murs  
- Calcul du score  
- API Laravel pour enregistrer les résultats

### 🇬🇧 Implemented
- Full Godot project structure  
- Scene / node architecture  
- NPC navigation system  
- Dynamic NPC reactions to player actions  
- Real-time furniture placement/removal  
- Wall color customization  
- Score calculation  
- Laravel API for result storage

## Roadmap / Planned Work

🇫🇷  
Les tâches en cours incluent :  
- Conteneurisation des applications (jeu + backend Laravel)  
- Génération aléatoire de décor / niveaux  
- Refonte du tutoriel  
- Création du menu principal et interface complète  
- Système jour/nuit  
- Système d’éclairage  
- Amélioration du comportement des NPC (éviter obstacles, collisions, etc.)  
- Ajout de nouveaux meubles  
- Limite de 4 meubles par pièce  
- Bouton “Fin de partie” + écran de récapitulatif  
- Optimisations générales

🇬🇧  
Ongoing tasks include:  
- Containerizing the applications (game + Laravel backend)  
- Random environment generation  
- Tutorial overhaul  
- Main menu and full UI  
- Day/night cycle  
- Lighting system  
- Improved NPC behavior (avoid obstacles, collisions, etc.)  
- Adding new furniture  
- Limit of 4 furniture items per room  
- “End game” button + recap screen  
- General optimizations

## Notes

🇫🇷  
Projet réalisé dans le cadre d’un travail d’équipe universitaire.  
Le jeu et le site web évoluent régulièrement.

🇬🇧  
Project created as part of a university team assignment.  
Both the game and the web platform evolve continuously.
