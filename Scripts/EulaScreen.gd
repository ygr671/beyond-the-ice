extends Control

const SETTINGS_PATH = "user://game_settings.cfg"
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const EULA_TEXT_FILE = "res://EULA.txt" # Fichier texte contenant votre EULA

@onready var accept_button = $MarginContainer/VBoxContainer/HBoxContainer/AcceptButton
@onready var checkbox = $MarginContainer/VBoxContainer/CheckBox
@onready var rich_text_label = $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel

func _ready():
	# 1. Charger le texte de l'EULA depuis un fichier
	# (Ne mettez jamais le texte légal directement dans le script !)
	var file = FileAccess.open(EULA_TEXT_FILE, FileAccess.READ)
	if FileAccess.file_exists(EULA_TEXT_FILE):
		rich_text_label.text = file.get_as_text()
		file.close()
	else:
		rich_text_label.text = "ERREUR : Fichier EULA.txt manquant."

	# 2. Gérer l'état du bouton "Accepter"
	accept_button.disabled = true
	checkbox.toggled.connect(_on_checkbox_toggled)

	# 3. Connecter les signaux des boutons
	accept_button.pressed.connect(_on_accept_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


# Active/Désactive le bouton "Accepter" selon la checkbox
func _on_checkbox_toggled(is_checked):
	accept_button.disabled = not is_checked


# L'utilisateur quitte le jeu
func _on_quit_pressed():
	get_tree().quit()


# L'utilisateur accepte
func _on_accept_pressed():
	# 1. Enregistrer l'acceptation
	var config = ConfigFile.new()
	# On charge d'abord au cas où d'autres settings existent déjà
	config.load(SETTINGS_PATH) 
	
	config.set_value("legal", "eula_accepted", true)
	
	config.save(SETTINGS_PATH)
	
	# 2. Continuer vers le menu principal
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
