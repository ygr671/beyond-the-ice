extends Node
var current_room: int  = 0
var is_day: bool = true

var furniture_list: Array[FurnitureInfo] = []
var room_satisfaction: Array[int] = []

signal environment_changed(change_type, data)
signal furniture_ordered(index)

func _ready():
	emit_signal("environment_changed", "init", null)
	emit_signal("furniture_ordered", "init")
	
	room_satisfaction.resize(6)
	room_satisfaction.fill(50)
