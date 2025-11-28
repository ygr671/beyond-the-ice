extends Control

@onready var order_furniture = $"."
@onready var charging_bar = $"../ui_charging_bar"
@onready var item_list = $"../ui_order_furniture/Panel/ItemList"
var furniture_order
var is_processing: bool = false

func _on_button_order_pressed() -> void:
	order_furniture.show()


func _on_item_list_item_selected(index: int) -> void:
	if is_processing:
		return
	is_processing = true
	if index == 0:  
		furniture_order = "bed"
	elif index == 1:
		furniture_order = "chair"
	elif index == 2:  
		furniture_order = "setup"
	is_processing = false
	order_furniture.hide()
	charging_bar.show()
	item_list.deselect_all()
	
	player_controller.emit_signal("furniture_ordered", furniture_order)
	
