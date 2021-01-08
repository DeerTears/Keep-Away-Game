extends Panel

onready var warmup = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Warmup
onready var roundtime = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Round
onready var postgame = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Postgame

onready var controls_button = $MarginContainer/HBoxContainer/Buttons/Controls
onready var video_button = $MarginContainer/HBoxContainer/Buttons/Video
onready var audio_button = $MarginContainer/HBoxContainer/Buttons/Audio
onready var back_button = $MarginContainer/HBoxContainer/Meta/Back

func _ready():
	controls_button.connect("pressed",self,"changemenu",["controls"])
	video_button.connect("pressed",self,"changemenu",["video"])
	audio_button.connect("pressed",self,"changemenu",["audio"])
	back_button.connect("pressed",self,"changemenu",["mainmenu"])
	warmup.value = GameInfo.warmup_time
	roundtime.value = GameInfo.round_time
	postgame.value = GameInfo.postgame_time
	warmup.connect("value_changed",self,"warmup_changed")
	roundtime.connect("value_changed",self,"roundtime_changed")
	postgame.connect("value_changed",self,"postgame_changed")
	$MarginContainer/HBoxContainer/Buttons/Controls.grab_focus()

func changemenu(scene:String):
	get_tree().change_scene("res://menus/%s.tscn" % [scene])

func warmup_changed(time:float):
	GameInfo.warmup_time = time
	check_times()

func roundtime_changed(time:float):
	GameInfo.round_time = time
	check_times()

func postgame_changed(time:float):
	GameInfo.postgame_time = time
	check_times()

func check_times():
	print("%s, %s, %s" %
	[GameInfo.warmup_time, GameInfo.round_time, GameInfo.postgame_time])
