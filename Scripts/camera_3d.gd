extends Camera3D

var mouse_position = Vector2()
var current_hovered_npc: NavigationNPC = null
var hover_timer: float = 0.0
const HOVER_DURATION: float = 3.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		check_npc_hover()

func _process(delta: float) -> void:
	if current_hovered_npc and hover_timer > 0:
		hover_timer -= delta
		if hover_timer <= 0:
			current_hovered_npc = null

func check_npc_hover():
	var space_state = get_world_3d().direct_space_state
	var ray_origin = project_ray_origin(mouse_position)
	var ray_end = ray_origin + project_ray_normal(mouse_position) * 1000.0
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)

	if result and result.collider is NavigationNPC:
		var npc = result.collider as NavigationNPC
		
		if current_hovered_npc != npc:
			current_hovered_npc = npc
			# fonction à mettre 
			# elle se lance lorsque la souris est sur un npc
			hover_timer = HOVER_DURATION
		else:
			hover_timer = HOVER_DURATION
