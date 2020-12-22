extends Panel

func changemenu(scene:String):
	get_tree().change_scene("res://menus/%s.tscn" % [scene])
