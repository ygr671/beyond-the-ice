extends Node

@onready var item_list = $"../ui_inventory"
@onready var color_menu = $"../ui_color_selection"
@onready var order_menu = $"../ui_order_furniture"



func _on_button_pressed() -> void:
	item_list.hide()


func _on_button_inventory_pressed() -> void:
	item_list.show()
	color_menu.hide()
	order_menu.hide()
