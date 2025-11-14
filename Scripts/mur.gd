extends Node3D
func set_color(new_color: Color, color_name: String):
	if $MeshInstance3D.material_override == null:
		$MeshInstance3D.material_override = StandardMaterial3D.new()
	$MeshInstance3D.material_override.albedo_color = new_color

	# émission du signal
	player_controller.emit_signal("environment_changed", "color_changed", color_name)
