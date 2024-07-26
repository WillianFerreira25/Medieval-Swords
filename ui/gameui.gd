extends CanvasLayer

@onready var timer_label: Label = %timerlabel
@onready var meat_label: Label = %meatlabel 
@onready var gold_label: Label = %goldlabel


func _process(delta: float):
	#update labels
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	gold_label.text = str(GameManager.gold_counter)


