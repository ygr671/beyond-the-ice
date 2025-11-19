extends Control

const SETTINGS_PATH = "user://game_settings.cfg"
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const EULA_TEXT_FILE = "res://EULA.txt" # Fichier texte contenant la EULA

@onready var accept_button = $MarginContainer/VBoxContainer/HBoxContainer/AcceptButton
@onready var checkbox = $MarginContainer/VBoxContainer/CheckBox
@onready var rich_text_label = $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel

func _ready():
	if FileAccess.file_exists(EULA_TEXT_FILE):
		var file = FileAccess.open(EULA_TEXT_FILE, FileAccess.READ)
		if file:
			rich_text_label.bbcode_text = file.get_as_text()
			file.close()
		else:
			rich_text_label.text = "ERREUR : Fichier EULA.txt trouvé, mais impossible de l'ouvrir."
	else:
		rich_text_label.text = "ERREUR : Fichier EULA.txt manquant."
	accept_button.disabled = true
	checkbox.toggled.connect(_on_checkbox_toggled)

	accept_button.pressed.connect(_on_accept_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_checkbox_toggled(is_checked):
	accept_button.disabled = not is_checked

func _on_quit_pressed():
	get_tree().quit()

func _on_accept_pressed():
	return;
