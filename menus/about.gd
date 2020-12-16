extends Panel

func _ready():
	$MarginContainer/VBoxContainer/Button.connect("pressed",get_tree(),"change_scene",["res://menus/mainmenu.tscn"])
