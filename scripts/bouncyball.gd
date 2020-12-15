extends RigidBody

func teleport(target:Vector3):
	transform.origin = target
	force_update_transform() # THIS WAS IT :DDD
	print(global_transform.origin)
	set_linear_velocity(Vector3.ZERO)
	set_angular_velocity(Vector3.ZERO)
	#set_transform(Transform(Basis(),target))
	yield(get_tree(),"idle_frame")
	

func _on_Area_area_entered(area):
	if area.get_parent().name == "Pits":
		teleport(Vector3(0,20,0))
		return
