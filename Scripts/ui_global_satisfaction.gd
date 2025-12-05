extends Control

@onready var bar = $VBoxContainer/ProgressBar

# On garde en mémoire la dernière valeur pour ne pas relancer le Tween pour rien
var derniere_cible: float = -1.0 

func _process(_delta: float) -> void:
	actualise()

func actualise() -> void:
	# 1. CORRECTION MATH : On utilise une variable locale qui repart de 0 à chaque calcul
	var total: float = 0.0
	var nombre_pieces = player_controller.room_satisfaction.size()
	
	# Sécurité : Si la liste est vide, on évite la division par zéro
	if nombre_pieces == 0:
		bar.value = 0
		return

	for i in player_controller.room_satisfaction:
		total += i
	
	# Calcul de la vraie moyenne
	var moyenne_actuelle = total / nombre_pieces
	
	# 2. CORRECTION TWEEN : On lance l'animation SEULEMENT si la valeur a changé
	# On utilise "is_equal_approx" pour éviter les bugs de virgule flottante (0.999 vs 1.0)
	if not is_equal_approx(moyenne_actuelle, derniere_cible):
		derniere_cible = moyenne_actuelle
		
		# Création du Tween
		var tween = create_tween()
		tween.tween_property(bar, "value", moyenne_actuelle, 0.4).set_trans(Tween.TRANS_CUBIC)
