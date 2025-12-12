extends Node


const WORK_DURATION: float = 15.0 


@onready var fill_timer: Timer = $"Timer"
@onready var progress_bar: ProgressBar = $"charging_bar_furniture"
@onready var succes: Label = $"succes"
@onready var failure: Label = $"failure"
@onready var item_list: ItemList = $"../ui_inventory/Panel/ItemList"
@onready var button_order: PanelContainer =$"../OrderMenu"


var furniture_list = player_controller.furniture_list

var is_filling: bool = false
var paused_time_left: float = 0.0


func _ready():
	player_controller.connect("furniture_ordered", Callable(self, "_on_furniture_ordered"))
	randomize()


func _process(_delta: float):

	if is_filling and not player_controller.is_day:
		pause_filling()


	if not is_filling and paused_time_left > 0.0 and player_controller.is_day:
		resume_filling()


	if is_filling:
		var temps_reel_ecoule = progress_bar.max_value - fill_timer.get_time_left()
		progress_bar.value = temps_reel_ecoule




func pause_filling():
	if is_filling:
		paused_time_left = fill_timer.get_time_left()
		fill_timer.stop()
		is_filling = false
		
	


func resume_filling():
	if paused_time_left > 0.0:
		fill_timer.start(paused_time_left)
		is_filling = true
		paused_time_left = 0.0
		


func wait_for_work_time(duration: float) -> void:
	var elapsed := 0.0

	while elapsed < duration:
		if player_controller.is_day:
			elapsed += get_process_delta_time()
		await get_tree().process_frame




func get_weighted_result(success_proba: float) -> int:
	var random_value: float = randf()
	return 1 if random_value < success_proba else 0


func _on_furniture_ordered(index: int):
	var rand
	start_filling_bar()

	await wait_for_work_time(WORK_DURATION) 


	if player_controller.is_day && player_controller.weather:
		rand = get_weighted_result(0.85)
	elif player_controller.is_day && !player_controller.weather:
		rand = get_weighted_result(0.50)
	else :
		rand = get_weighted_result(0.0)

	_on_timer_timeout(rand)


	if rand == 1:
		furniture_list[index].stock += furniture_list[index].restock_count
		item_list.set_item_text(index, furniture_list[index].name + " (" + str(furniture_list[index].stock) + ")")




func start_filling_bar():
	button_order.hide()
	progress_bar.show()
	progress_bar.value = 0.0
	is_filling = true
	paused_time_left = 0.0
	fill_timer.start(WORK_DURATION) 
	



func _on_timer_timeout(random: int):
	is_filling = false
	progress_bar.value = progress_bar.max_value
	progress_bar.hide()
	progress_bar.value = progress_bar.min_value
	if random == 1:

		succes.show()
	else:
		failure.show()
	button_order.show()
	await get_tree().create_timer(2.0).timeout

	if random == 1:
		succes.hide()
	else:
		failure.hide()
	
