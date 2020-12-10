extends RigidBody

func teleport(target:Node):
	print(target)
	if target == null:
		return
	var teleport_point = target.translation
	print(get_translation())
	set_translation(teleport_point) # why this no work? eh...

func _on_Area_area_entered(area):
	if area.get_collision_layer() == 2147483776:
		teleport(get_node_or_null("/root/Spatial/"))
