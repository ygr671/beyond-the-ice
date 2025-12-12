extends Control

const CREDITS_TEXT_FILE = "user://legal/Credits.txt"

@onready var rich_text_label = $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel

func _ready():
	
	if FileAccess.file_exists(CREDITS_TEXT_FILE):
		
		
		var file = FileAccess.open(CREDITS_TEXT_FILE, FileAccess.READ)
		
		
		if file:
			
			rich_text_label.bbcode_text = file.get_as_text()
			file.close()
		else:
			rich_text_label.text = "ERREUR : Fichier Credits.txt trouvé, mais impossible de l'ouvrir."
			
	else:
		
		rich_text_label.text = "ERREUR : Fichier Credits.txt manquant."

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
