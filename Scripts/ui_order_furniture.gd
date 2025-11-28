extends Control

@onready var order_furniture = $"."

func _on_button_order_pressed() -> void:
	order_furniture.show()


func _on_item_list_item_selected(index: int) -> void:
	order_furniture.hide()
	await get_tree().create_timer(15.0).timeout
	player_controller.bed_in_invetory +=1
	if index == 0: 
		emit_signal("furniture_ordered", "bed")
	elif index == 1:
		emit_signal("furniture_ordered", "chair")
	elif index == 2: 
		emit_signal("furniture_ordered", "setup")
