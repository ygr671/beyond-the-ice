extends Control

@onready var order_furniture = $"."




func _on_button_order_pressed() -> void:
	order_furniture.show()


func _on_item_list_item_selected(index: int) -> void:
	if index == 0: 
		emit_signal("furniture_ordered", "bed")
		order_furniture.hide()
	elif index == 1:
		emit_signal("furniture_ordered", "chair")
		order_furniture.hide()
	elif index == 2: 
		emit_signal("furniture_ordered", "setup")
		order_furniture.hide()
