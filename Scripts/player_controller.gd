extends Node
var current_room: int  = 0

signal environment_changed(change_type, data)
func _ready():
	emit_signal("environment_changed", "init", null)
