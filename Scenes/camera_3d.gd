extends Camera3D

var mouse = Vector2()
var target: Node3D = null
@onready var ui_label: Label = $"../CanvasLayer/Label"

func _ready():
	ui_label.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mouse = event.position
		select_npc()

func select_npc():
	var space_state = get_world_3d().direct_space_state
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 1000.0
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	var result = space_state.intersect_ray(query)

	if result and result.has("collider") and result.collider is NavigationNPC:
		var npc = result.collider

		if target == npc:
			# Si on reclique sur le même NPC : désélection
			target = null
			ui_label.visible = false
			npc.speed_boost()
		else:
			# Nouveau NPC sélectionné
			target = npc
			ui_label.text = npc._display()
			ui_label.visible = true
			npc._set_destination_null()
