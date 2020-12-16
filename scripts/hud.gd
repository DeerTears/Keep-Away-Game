extends Control

onready var timer_label = $Control/Timer/Label
onready var score_label = $Control/Score/MarginContainer/VBox/Label

func _process(_delta):
	if GameInfo.is_stopped():
		return
	timer_label.text = "%d" % [GameInfo.time_left]

func update_score(amount:int):
	score_label.text = "%03d" % [amount]
