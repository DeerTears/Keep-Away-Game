extends Node

# consider: extend a timer, when we run ourselves, we provide the amount of time_left to every other node in the scene

# scoring

var p0_score: int = 0
var p1_score: int = 0
var p2_score: int = 0
var p3_score: int = 0

# respawning
# tells every player where they should respawn when they call get_my_respawn_location(controlling_player)

# pre-emptive debug: if player teleports always == Vector3.ZERO, then SpawnLocations.tscn is missing from the level

var p0_respawn_location = Vector3.ZERO
var p1_respawn_location = Vector3.ZERO
var p2_respawn_location = Vector3.ZERO
var p3_respawn_location = Vector3.ZERO

func get_my_respawn_location(num:int) -> Vector3:
	match num:
		0:
			return p0_respawn_location
		1:
			return p1_respawn_location
	print("Error, could not find player number to teleport")
	return Vector3.ZERO

# gamestate machine
# manages timers and such

enum GameStates {
	LOADING,
	WARMUP,
	COUNTDOWN,
	STARTED,
	POSTGAME,
}

var current_gamestate: int = GameStates.LOADING

var time_warmup: float = 5.0
var time_countdown: float = 3.0
var time_started: float = 60.0
var time_postgame: float = 10.0

func switch_gamestate(state:int):
	match state:
		GameStates.LOADING:
			pass
		GameStates.WARMUP:
			reset_scores()
			yield(get_tree().create_timer(time_warmup),"timeout")
			switch_gamestate(GameStates.COUNTDOWN)
		GameStates.COUNTDOWN:
			yield(get_tree().create_timer(time_countdown),"timeout")
			switch_gamestate(GameStates.STARTED)
		GameStates.STARTED:
			yield(get_tree().create_timer(time_started),"timeout")
			switch_gamestate(GameStates.POSTGAME)
		GameStates.POSTGAME:
			determine_winner()
			yield(get_tree().create_timer(time_postgame),"timeout")
			switch_gamestate(GameStates.WARMUP)

func determine_winner():
	if p0_score > p1_score:
		print("p0 is winner!")
	if p1_score > p0_score:
		print("p1 is winner!")
	if p1_score == p0_score:
		print("it's a tie!")

func add_score(player:int,score:int):
	match player:
		0:
			p0_score += score
			print("p0's score is now %s" % [p0_score])
		1:
			p1_score += score
			print("p1's score is now %s" % [p1_score])

func reset_scores():
	p0_score = 0
	p1_score = 0
