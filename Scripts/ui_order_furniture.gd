extends Control

@onready var order_furniture = $"."
@onready var charging_bar = $"../ui_charging_bar"
@onready var item_list = $"../ui_order_furniture/Panel/ItemList"
@onready var err_message = $"../ui_order_furniture/err_message"
var furniture_order
var is_processing: bool = false

func _on_button_order_pressed() -> void:
	order_furniture.show()


func _on_item_list_item_selected(index: int) -> void:
	if is_processing:
		item_list.deselect_all()
		err_message.show()
		await get_tree().create_timer(2.0).timeout
		err_message.hide()
		return
	is_processing = true
	if index == 0:  
		furniture_order = "bed"
	elif index == 1:
		furniture_order = "chair"
	elif index == 2:  
		furniture_order = "setup"
	order_furniture.hide()
	item_list.deselect_all()
	player_controller.emit_signal("furniture_ordered", furniture_order)
	await get_tree().create_timer(15.0).timeout
	is_processing = false
	
