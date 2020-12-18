extends Panel

onready var play_romp = $MarginContainer/VBoxContainer/GridContainer/Romp
onready var play_pits = $MarginContainer/VBoxContainer/GridContainer/Pits
onready var about = $MarginContainer/VBoxContainer/GridContainer/About
onready var quit = $MarginContainer/VBoxContainer/GridContainer/Quit

func _ready():
	play_romp.connect("pressed",self,"play_level",["romp"])
	play_pits.connect("pressed",self,"play_level",["pits"])
	about.connect("pressed",get_tree(),"change_scene",["res://menus/about.tscn"])
	quit.connect("pressed",get_tree(),"quit")

# todo: re-enable this so you can call "in-game" to gameinfo
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
