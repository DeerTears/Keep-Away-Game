extends RigidBody

func teleport(target:Vector3):
	self.transform.origin = target
	yield(get_tree(),"idle_frame")
	print(transform.origin)

func _on_Area_area_entered(area):
	if area.get_collision_layer() == 2147483776:
		teleport(Vector3(rand_range(-50,50), 50, rand_range(-50, 50)))
