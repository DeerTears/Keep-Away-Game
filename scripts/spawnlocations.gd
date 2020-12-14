extends Spatial

onready var p0 = $Player0
onready var p1 = $Player1

var p0_position: Vector3
var p1_position: Vector3

func _ready():
	p0_position = p0.global_transform.origin
	p1_position = p1.global_transform.origin
	print("%s is the absolute position of p%s" % [p0_position, "0"])
	print("%s is the absolute position of p%s" % [p1_position, "1"])
	GameInfo.p0_respawn_location = p0_position
	GameInfo.p1_respawn_location = p1_position
