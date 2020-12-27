extends RigidBody

var gamemode: int

const team = {
	"none":-1,
	"red":0,
	"blue":1,
}

onready var mesh_neutral = $Neutral
onready var mesh_red = $Red
onready var mesh_blue = $Blue

var owned_by_team: int = -1 # none == -1
var last_hit_by_player: int = -1 # none == -1
var ball_value: int = 1

func assign_gamemode(current_gamemode:int):
	gamemode = current_gamemode
	match gamemode:
		GameInfo.GameModes.KEEPAWAY:
			update_appearance(-1) # refactor: replace -1s with team["none"]
		GameInfo.GameModes.SOCCER:
			update_appearance(owned_by_team)
		GameInfo.GameModes.SANDBOX:
			update_appearance(-1)

func teleport(target:Vector3):
	transform.origin = target
	force_update_transform() # THIS WAS IT :DDD
	print(global_transform.origin)
	set_linear_velocity(Vector3.ZERO)
	set_angular_velocity(Vector3.ZERO)
	update_appearance(-1)
	last_hit_by_player = -1 # refactor: replace -1s with team["none"]
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
	if gamemode == GameInfo.GameModes.KEEPAWAY or gamemode == GameInfo.GameModes.SANDBOX:
		$Neutral.hide()
		last_hit_by_player = player_number
		update_appearance(player_number) # -1 for none, 0 for red, 1 for blue

func update_appearance(team:int):
	match team:
		0: # refactor: replace -1. 0, and 1 with team["none", "red" and "blue"]
			$Red.show()
			$Blue.hide()
		1:
			$Blue.show()
			$Red.hide()
		-1:
			$Neutral.show()
			$Blue.hide()
			$Red.hide()
