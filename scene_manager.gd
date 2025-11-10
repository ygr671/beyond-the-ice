extends Node

# Pile pour stocker les chemins des scènes précédentes
var scene_stack : Array = []

# Aller vers une nouvelle scène
func go_to_scene(new_scene_path: String) -> void:
	# Si la pile est vide ou si on change de scène, stocke le chemin de la scène actuelle
	# Attention : on **doit connaître le chemin actuel**, donc on le passe depuis le bouton
	scene_stack.append(new_scene_path) # on stocke le chemin qu'on quitte
	get_tree().change_scene_to_file(new_scene_path)

# Revenir à la scène précédente
func go_back() -> void:
	if scene_stack.size() > 1:
		# Retire la scène actuelle
		scene_stack.pop_back()
		# Va à la scène précédente
		var previous_path = scene_stack[scene_stack.size() - 1]
		get_tree().change_scene_to_file(previous_path)
