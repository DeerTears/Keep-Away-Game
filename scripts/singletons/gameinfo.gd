extends Node

# notes:

# each level must have

# a SpawnLocation object with configured child locations
# Players

var p0_respawn_location: Vector3
var p1_respawn_location: Vector3

func get_my_respawn_location(num:int) -> Vector3:
	match num:
		0:
			return p0_respawn_location
		1:
			return p1_respawn_location
	print("Error, could not find player number to teleport")
	return Vector3.ZERO
