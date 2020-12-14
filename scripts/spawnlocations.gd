extends Spatial

onready var p0 = $Player0
onready var p1 = $Player1
onready var p2 = $Player2
onready var p3 = $Player3

var p0_position: Vector3
var p1_position: Vector3
var p2_position: Vector3
var p3_position: Vector3

func _ready():
	for i in self.get_child_count():
		get_child(i).get_child(0).hide()
	p0_position = p0.global_transform.origin
	p1_position = p1.global_transform.origin
	p2_position = p2.global_transform.origin
	p3_position = p3.global_transform.origin
	
	GameInfo.p0_respawn_location = p0_position
	GameInfo.p1_respawn_location = p1_position
	GameInfo.p2_respawn_location = p2_position
	GameInfo.p3_respawn_location = p2_position
