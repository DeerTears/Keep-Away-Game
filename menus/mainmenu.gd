extends Panel

onready var play_romp = $MarginContainer/VBoxContainer/GridContainer/Romp
onready var play_pits = $MarginContainer/VBoxContainer/GridContainer/Pits
onready var about = $MarginContainer/VBoxContainer/GridContainer/About
onready var quit = $MarginContainer/VBoxContainer/GridContainer/Quit

func _ready():
	play_romp.connect("pressed",get_tree(),"change_scene",["res://levels/romping.tscn"])
	play_pits.connect("pressed",get_tree(),"change_scene",["res://levels/2pits.tscn"])
	about.connect("pressed",get_tree(),"change_scene",["res://menus/mainmenu.tscn"])
	quit.connect("pressed",get_tree(),"quit")

#func play_level(level:String):
#	match level:
#		"romp":
#			get_tree().change_scene("res://levels/romping.tscn")
#		"pits":
#			get_tree().change_scene("res://levels/2pits.tscn")
