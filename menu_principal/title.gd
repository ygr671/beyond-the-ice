extends Label

var amplitude = 10
var speed = 3
var base_position : Vector2
var last_toggle_time : int = 0


func _ready():
	base_position = position
	last_toggle_time = Time.get_ticks_msec()


@warning_ignore("unused_parameter")
func _process(delta: float):
	var current_time = Time.get_ticks_msec()
	position.y = base_position.y + sin(current_time * speed * 0.001) * amplitude
