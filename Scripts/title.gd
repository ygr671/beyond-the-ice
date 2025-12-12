## @class_doc
## @description Script d'animation pour un Label (titre) qui applique un mouvement
## d'oscillation verticale de type "pulsé" ou "flottant" en utilisant la fonction sinus.
## @tags ui, animation, movement, effects

extends Label

## @var_doc
## @description Amplitude maximale du mouvement vertical (en pixels).
## @tags config
var amplitude = 100

## @var_doc
## @description Vitesse du mouvement d'oscillation. Augmenter cette valeur accélére la pulsation.
## @tags config
var speed = 3

## @var_doc
## @description Position verticale initiale du label, stockée lors du _ready.
## @tags state, position
var base_position : Vector2

## @var_doc
## @description Horodatage de la dernière action (non utilise dans le code actuel, peut être réservé).
## @tags cleanup
var last_toggle_time : int = 0


## @func_doc
## @description Initialisation. Enregistre la position de base du label.
## @tags init
func _ready():
	base_position = position
	last_toggle_time = Time.get_ticks_msec()


## @func_doc
## @description Mise à jour par frame pour calculer la nouvelle position verticale.
## Utilise la fonction sinus pour créer une oscillation qui est ensuite mise au carré (sin * sin)
## pour concentrer le mouvement autour du haut (amplitude positive), créant un effet de pulsation.
## @param delta: float Temps écoulé depuis la dernière frame (non utilisé ici car on utilise Time.get_ticks_msec).
## @tags core, animation
@warning_ignore("unused_parameter")
func _process(delta: float):
	var current_time = Time.get_ticks_msec()
	
	# Formule pour un mouvement pulsé/flottant : sin(t) * amplitude * sin(t)
	# L'utilisation de sin(t) * sin(t) assure que le mouvement reste principalement dans
	# l'amplitude positive (au-dessus de base_position.y), car sin^2 est toujours positif.
	position.y = base_position.y + sin(current_time * speed * 0.001) * amplitude * sin(current_time * speed * 0.001)
