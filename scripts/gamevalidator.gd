extends Spatial

func _ready():
	GameInfo.ingame = true
	GameInfo.switch_gamestate(GameInfo.GameStates.WARMUP)
	yield(get_tree(),"idle_frame")
	queue_free() # i have to go now, my planet needs me
