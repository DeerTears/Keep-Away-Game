extends Spatial

class_name Coin

enum states {
	DISABLED,
	SPAWNED,
	TAKEN,
}

var current_state = states.DISABLED

onready var model = $MeshInstance
onready var area = $Area
onready var animator = $AnimationPlayer
onready var sound_collect = $Collect

export var respawn_time: float = 10

enum qualities {
	GARBAGE,
	BRONZE,
	SILVER,
	GOLD
}

var coin_quality: int

func _ready():
	randomize()
	var random = randi() % 5
	if random >= 4:
		coin_quality = qualities.get("GOLD")
		check_quality()
		return
	if random >= 2:
		coin_quality = qualities.get("SILVER")
		check_quality()
		return
	if random <= 1:
		coin_quality = qualities.get("BRONZE")
		check_quality()
		return
	
func check_quality():
	match coin_quality:
		qualities.BRONZE:
			model.scale = Vector3.ONE * 0.25
		qualities.SILVER:
			model.scale = Vector3.ONE * 0.65
		qualities.GOLD:
			model.scale = Vector3.ONE * 1

func collect(): # todo: replace duplicate calls with change_to_state
	# todo 2: add a check so coins can't respawn after being disabled
	area.monitorable = false
	sound_collect.pitch_scale = rand_range(3.25,3.5) - coin_quality
	sound_collect.play()
	animator.play("Collected")
	yield(animator,"animation_finished")
	hide()
	yield(get_tree().create_timer(respawn_time),"timeout")
	show()
	area.monitorable = true
	animator.play("Idle")

func change_to_state(state:int):
	current_state = state
	match state:
		states.DISABLED:
			area.monitorable = false
			hide()
		states.SPAWNED:
			area.monitorable = true
			show()
		states.TAKEN:
			area.monitorable = false
			hide()
			yield(get_tree().create_timer(respawn_time),"timeout")
			change_to_state(states.SPAWNED)
