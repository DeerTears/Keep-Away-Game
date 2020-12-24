extends RigidBody

onready var mesh_neutral = $Neutral
onready var mesh_red = $Red
onready var mesh_blue = $Blue

var last_hit_by_player: int = -1 # none == -1
var ball_value: int = 1

func teleport(target:Vector3):
	transform.origin = target
	force_update_transform() # THIS WAS IT :DDD
	print(global_transform.origin)
	set_linear_velocity(Vector3.ZERO)
	set_angular_velocity(Vector3.ZERO)
	#set_transform(Transform(Basis(),target))
	mesh_red.hide()
	mesh_blue.hide()
	mesh_neutral.show()
	last_hit_by_player = -1
	yield(get_tree(),"idle_frame")

func _on_Area_area_entered(area):
	if area.get_parent().name == "Pits":
		teleport(Vector3(0,20,0))
		return
	if area.get_parent().name == "Scorezone":
		$Area.set_deferred("monitoring", false)
		score()

func score():
	GameInfo.add_score(last_hit_by_player, ball_value)
	# bug : player ui does not update with this kind of scoring
	queue_free()

func update_last_hit(player_number:int):
	$Neutral.hide()
	last_hit_by_player = player_number
	match player_number:
		0:
			$Red.show()
			$Blue.hide()
		1:
			$Blue.show()
			$Red.hide()
		-1:
			$Neutral.show()
			$Blue.hide()
			$Red.hide()
