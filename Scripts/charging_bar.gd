extends Control
@onready var fill_timer: Timer = $"Timer"
@onready var progress_bar: ProgressBar = $"charging_bar_furniture"
@onready var succes : Label = $"succes"
@onready var failure : Label = $"failure"
@onready var item_list : ItemList =  $"../ui_inventory/Panel/ItemList"

var furniture_list = player_controller.furniture_list

var is_filling: bool = false


func _ready():
	player_controller.connect("furniture_ordered", Callable(self, "_on_furniture_ordered"))
	randomize()
	
# --- Mise à jour de la barre et du Label à chaque frame ---
func _process(_delta: float):
	if is_filling:
		var temps_reel_ecoule = progress_bar.max_value - fill_timer.get_time_left()
		progress_bar.value = temps_reel_ecoule
		
		
func get_weighted_result(success_proba: float) -> int:
	# Génère un nombre aléatoire entre 0.0 et 1.0
	var random_value: float = randf()
	if random_value < success_proba:
		return 1 
	else:
		return 0
		
func _on_furniture_ordered(index: int):
	var rand;
	start_filling_bar()
	await get_tree().create_timer(15.0).timeout
	if player_controller.is_day:
		rand = get_weighted_result(75)
	else:
		rand = get_weighted_result(0.4)
	
	_on_timer_timeout(rand)
	if rand == 1:
		furniture_list[index].stock += 1
		item_list.set_item_text(index, str(furniture_list[index].stock))
		item_list.set_item_text(index, furniture_list[index].name + " (" + str(furniture_list[index].stock) + ")")
	
	

func start_filling_bar(): 
	progress_bar.show()    
	progress_bar.value = 0.0  
	is_filling = true  
	fill_timer.start()


func _on_timer_timeout(random: int):
	is_filling = false
	progress_bar.value = progress_bar.max_value
	progress_bar.hide()
	progress_bar.value = progress_bar.min_value
	if(random == 1):
		succes.show()
	else:
		failure.show()
	
	await get_tree().create_timer(2.0).timeout
	if(random == 1):
		succes.hide()
	else:
		failure.hide()
