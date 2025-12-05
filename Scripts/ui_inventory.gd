extends Node

@onready var item_list = $"../ui_inventory"

func _on_button_pressed() -> void:
	item_list.hide()


func _on_button_inventory_pressed() -> void:
	item_list.show()
