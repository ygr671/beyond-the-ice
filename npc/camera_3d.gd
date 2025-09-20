extends Camera3D

var mouse = Vector2()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT :
		mouse = event.position
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_selection()
			
			
			
func get_selection():
	var space_state = get_world_3d().direct_space_state
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 1000.0  
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	
	var result = space_state.intersect_ray(query)
	
	print(result)
	
	
