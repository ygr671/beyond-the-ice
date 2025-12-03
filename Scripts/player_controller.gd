extends Node
var current_room: int  = 0

var furniture_count = [0, 0, 0]

signal environment_changed(change_type, data)
signal furniture_ordered(index)

func _ready():
	emit_signal("environment_changed", "init", null)
	emit_signal("furniture_ordered", "init")
