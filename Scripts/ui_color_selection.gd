extends Control

@onready var color_menu = $"."
var already_changed = []


func _ready() -> void:
	already_changed.resize(6)
	already_changed.fill(false)

func _on_button_pressed() -> void:
	color_menu.hide()

func _on_orange_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_ORANGE)
	color_menu.hide()

func _on_red_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_RED)
	color_menu.hide()

func _on_green_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GREEN)
	color_menu.hide()

func _on_white_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.WHITE_SMOKE)
	color_menu.hide()

func _on_gray_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GRAY)
	color_menu.hide()

func _on_black_pressed() -> void:
	if already_changed[player_controller.current_room]:
		color_menu.hide()
		return
	already_changed[player_controller.current_room] = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DIM_GRAY)
	color_menu.hide()
