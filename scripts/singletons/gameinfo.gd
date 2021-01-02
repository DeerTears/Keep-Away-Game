extends Timer

# using Timer to allow global access of time_left property, yield and create_timer is still used to handle the state machine

# gamemode

enum GameModes {
	GRAFFITI,
	KEEPAWAY,
	SOCCER,
	SANDBOX
}

var gamemode = GameModes.GRAFFITI

# for graffiti

var graffiti_balls_owned = [[],[],[],[]]

# gamestate/round statemachine

var ingame: bool = false # don't start the machine if we're not in a game yet
var start_with_debug_trails = false

enum GameStates {
	LOADING,
	WARMUP,
	COUNTDOWN,
	STARTED,
	POSTGAME,
}

var current_gamestate: int = GameStates.LOADING
var loading_time: float = 2.0
var warmup_time: float = 10.0
var countdown_time: float = 6.0
var round_time: float = 60.0
var postgame_time: float = 10.0

func _ready():
	ingame = false
	set_autostart(false)
	set_one_shot(true)
	switch_gamestate(GameStates.LOADING)

func switch_gamestate(state:int): # self-contained and recursive
	if not ingame: # todo: make this turn on/turn off from menus
		return
	current_gamestate = state # update our state, so other objects can read what's going on
	match state:
		GameStates.LOADING:
			print("Loading...")
			# Hide Coins
			get_tree().call_group("Coins","change_to_state", Coin.states.DISABLED)
			yield(get_tree().create_timer(loading_time),"timeout")
			switch_gamestate(GameStates.WARMUP)
			get_tree().call_group("Balls","hide")
			get_tree().call_group("Balls","assign_gamemode", gamemode)
		GameStates.WARMUP:
			reset_scores()
			set_debug_trails(start_with_debug_trails)
			# Inform players
			print("Warming up...")
			get_tree().call_group("Players","show_notice",HUD.notice.WARMUP)
			# Let other objects get our wait_time
			start(warmup_time)
			# Hide Coins and Balls
			get_tree().call_group("Coins","change_to_state", Coin.states.DISABLED)
			get_tree().call_group("Balls","hide")
			yield(get_tree().create_timer(warmup_time),"timeout")
			switch_gamestate(GameStates.COUNTDOWN)
		
		GameStates.COUNTDOWN:
			print("Ready...")
			# Reset and Freeze Players
			get_tree().call_group("Players","respawn")
			get_tree().call_group("Players","enable_movement",false)
			get_tree().call_group("Players","show_notice",HUD.notice.INTRO_GRAFFITI)
			# Spawn Coins and Balls
			get_tree().call_group("Coins","change_to_state", Coin.states.SPAWNED)
			get_tree().call_group("Balls","show")
			get_tree().call_group("Balls","assign_gamemode", gamemode)
			get_tree().call_group("Balls","update_last_hit", -1) # neutral == -1
			# Let other objects get our wait_time
			start(countdown_time)
			# Start the countdown timer
			yield(get_tree().create_timer(countdown_time),"timeout")
			switch_gamestate(GameStates.STARTED)
		
		GameStates.STARTED:
			print("Go!")
			# Release Players
			get_tree().call_group("Players","enable_movement",true)
			get_tree().call_group("Players","show_notice",HUD.notice.GO)
			# Let other objects get our wait_time
			start(round_time)
			# Wait until round is over
			yield(get_tree().create_timer(round_time),"timeout")
			switch_gamestate(GameStates.POSTGAME)
			
		GameStates.POSTGAME:
			print("Finish!")
			# Find out who won
			determine_winner()
			# todo: make sure coins don't respawn when collected and disabled
			get_tree().call_group("Coins","change_to_state", Coin.states.DISABLED)
			yield(get_tree().create_timer(postgame_time),"timeout")
			switch_gamestate(GameStates.WARMUP)
			

# respawning

# tip: if a player teleports to 0,0,0, then SpawnLocations.tscn and its children are missing from the level

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

# scoring

var p0_score: int = 0
var p1_score: int = 0
var p2_score: int = 0
var p3_score: int = 0

var player_scores = [ # todo, make the above variables condensed and easier to access variably
	0,
	0,
	0,
	0,
]

func determine_winner():
	match gamemode:
		GameModes.KEEPAWAY:
			pass
		GameModes.GRAFFITI:
			get_tree().call_group("Balls","determine_winner")
			yield(get_tree(),"idle_frame")
			p0_score = graffiti_balls_owned[0].size()
			p1_score = graffiti_balls_owned[1].size()
			p2_score = graffiti_balls_owned[2].size()
			p3_score = graffiti_balls_owned[3].size()
			print("%s, %s, %s, %s" % [p0_score, p1_score, p2_score, p3_score])
	if p0_score > p1_score:
		print("p0 is the winner!")
		get_tree().call_group("Players","show_notice",HUD.notice.WIN)
	if p1_score > p0_score:
		print("p1 is the winner!")
		get_tree().call_group("Players","show_notice",HUD.notice.LOSE)
	if p1_score == p0_score:
		print("it's a tie!")
		get_tree().call_group("Players","show_notice",HUD.notice.TIE)

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
	p2_score = 0
	p3_score = 0
	print("All scores reset.")
	if gamemode == GameModes.GRAFFITI:
		graffiti_balls_owned[0].clear()
		graffiti_balls_owned[1].clear()
		graffiti_balls_owned[2].clear()
		graffiti_balls_owned[3].clear()
	get_tree().call_group("Players", "reset_score_label")

func set_debug_trails(enabled:bool):
	get_tree().call_group("Players", "set_debug_trails", enabled)
