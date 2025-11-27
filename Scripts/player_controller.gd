extends Node
var current_room: int  = 0

signal environment_changed(change_type, data)
signal furniture_ordered(furniture_type)
func _ready():
	emit_signal("environment_changed", "init", null)
	emit_signal("furniture_ordered", "init")
