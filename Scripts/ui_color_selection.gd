extends Control

@onready var color_menu = $"."
#On charge chaque variente de couleur
@onready var orange = preload("res://materials/Wall/Orange.tres")
@onready var red = preload("res://materials/Wall/Red.tres")
@onready var gray = preload("res://materials/Wall/Gray.tres")
@onready var white = preload("res://materials/Wall/White.tres")
@onready var black = preload("res://materials/Wall/Black.tres")
@onready var green = preload("res://materials/Wall/Green.tres")

var already_changed = false;

func _on_button_pressed() -> void:
	color_menu.hide()

func _on_orange_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_ORANGE)
	color_menu.hide()

func _on_red_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_RED)
	color_menu.hide()

func _on_green_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GREEN)
	color_menu.hide()

func _on_white_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.WHITE_SMOKE)
	color_menu.hide()

func _on_gray_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DARK_GRAY)
	color_menu.hide()

func _on_black_pressed() -> void:
	if already_changed:
		color_menu.hide()
		return
	already_changed = true
	player_controller.emit_signal("environment_changed", "color_changed", Color.DIM_GRAY)
	color_menu.hide()
