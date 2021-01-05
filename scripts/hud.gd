extends Control

class_name HUD

onready var timer_label = $Control/Timer/Label
onready var score_label = $Control/Score/MarginContainer/VBox/Label
onready var notifier_label = $Control/Notifier/Control/Label
onready var notifier = $Control/Notifier

enum notice {
	INTRO_KEEPAWAY,
	INTRO_SOCCER,
	INTRO_SKEEBALL,
	INTRO_GRAFFITI,
	SECONDS_30,
	SECONDS_10,
	LOSE,
	WIN,
	TIE,
	GO,
	READY,
	WARMUP,
	POSTGAME,
}

var notify_msg: Dictionary = {
	notice.INTRO_SKEEBALL:"Hit balls into the net for points before time runs out!",
	notice.INTRO_SOCCER:"Hit the ball into your team's net before time runs out!",
	notice.INTRO_KEEPAWAY:"Knock your opponents balls out of the court, and protect your own!",
	notice.INTRO_GRAFFITI:"Hit balls to claim them! Whoever has the most at the end, wins!",
	notice.SECONDS_30:"30 Seconds Left!",
	notice.SECONDS_10:"10 Seconds Left!",
	notice.LOSE:"Player 2 Wins!",
	notice.WIN:"Player 1 Wins!",
	notice.TIE:"It's a tie!",
	notice.POSTGAME:"Press ESC to quit to the main menu.",
	notice.GO:"Go!",
	notice.READY:"Ready?",
	notice.WARMUP:"The round will begin after a quick warmup."
	}

func _process(_delta):
	if GameInfo.is_stopped():
		return
	timer_label.text = "%d" % [GameInfo.time_left]

func update_score(amount:int):
	score_label.text = "%03d" % [amount]

func show_notice(notice_type:int):
	notifier_label.text = notify_msg.get(notice_type)
	notifier.show()
	var onscreen_duration = 5.0
	match notice_type:
		notice.READY:
			onscreen_duration = 1.0
		notice.GO:
			onscreen_duration = 3.0
		notice.WIN:
			onscreen_duration = (GameInfo.postgame_time / 2) - 0.01 # - 0.01 to ensure warmup notice doesn't get overwritten
			yield(get_tree().create_timer(onscreen_duration),"timeout")
			show_notice(notice.POSTGAME)
		notice.LOSE:
			onscreen_duration = (GameInfo.postgame_time / 2) - 0.01 # - 0.01 to ensure warmup notice doesn't get overwritten
			yield(get_tree().create_timer(onscreen_duration),"timeout")
			show_notice(notice.POSTGAME)
		notice.TIE:
			onscreen_duration = (GameInfo.postgame_time / 2) - 0.01 # - 0.01 to ensure warmup notice doesn't get overwritten
			yield(get_tree().create_timer(onscreen_duration),"timeout")
			show_notice(notice.POSTGAME)
		notice.POSTGAME:
			onscreen_duration = (GameInfo.postgame_time / 2) - 0.01 # - 0.01 to ensure warmup notice doesn't get overwritten	yield(get_tree().create_timer(onscreen_duration),"timeout")
	notifier.hide()
