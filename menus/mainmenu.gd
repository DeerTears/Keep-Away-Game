extends Panel

onready var play_romp = $MarginContainer/VBoxContainer/HBoxContainer2/Play/GridContainer/Romp
onready var play_pits = $MarginContainer/VBoxContainer/HBoxContainer2/Play/GridContainer/Pits
onready var play_keep = $MarginContainer/VBoxContainer/HBoxContainer2/Play/GridContainer/Keep
onready var about = $MarginContainer/VBoxContainer/HBoxContainer2/About
onready var quit = $MarginContainer/VBoxContainer/HBoxContainer2/Quit
onready var settings = $MarginContainer/VBoxContainer/HBoxContainer2/Customize/GridContainer/Settings

func _ready():
	play_romp.connect("pressed",self,"play_level",["romp"])
	play_pits.connect("pressed",self,"play_level",["pits"])
	play_keep.connect("pressed",self,"play_level",["keep"])
	settings.connect("pressed",get_tree(),"change_scene",["res://menus/settings.tscn"])
	about.connect("pressed",get_tree(),"change_scene",["res://menus/about.tscn"])
	quit.connect("pressed",get_tree(),"quit")

func play_level(level:String):
	match level:
		"romp":
			GameInfo.ingame = true
			GameInfo.switch_gamestate(GameInfo.GameStates.LOADING)
			get_tree().change_scene("res://levels/romp_multi.tscn")
		"pits":
			GameInfo.ingame = true
			GameInfo.switch_gamestate(GameInfo.GameStates.LOADING)
			get_tree().change_scene("res://levels/2pits.tscn")
