extends Panel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_BackButton_pressed():
	get_tree().change_scene("res://menus/mainmenu.tscn")

func _on_Local_pressed():
	play_local_level("romp")

func _on_Online_pressed():
	get_tree().change_scene("res://menus/online.tscn")

func play_local_level(level:String):
	MenuMusic.stop()
	match level:
		"romp":
			GameInfo.ingame = true
			GameInfo.switch_gamestate(GameInfo.GameStates.LOADING)
			get_tree().change_scene("res://levels/romp_multi.tscn")
#		"pits":
#			GameInfo.ingame = true
#			GameInfo.switch_gamestate(GameInfo.GameStates.LOADING)
#			get_tree().change_scene("res://levels/2pits.tscn")
#		"keep":
#			GameInfo.ingame = true
#			GameInfo.switch_gamestate(GameInfo.GameStates.LOADING)
#			get_tree().change_scene("res://levels/keep.tscn")
