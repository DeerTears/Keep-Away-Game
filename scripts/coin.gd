extends Spatial

onready var model = $MeshInstance
onready var area = $Area
onready var animator = $AnimationPlayer

export var respawn_time: float = 5.0

enum qualities {
	BRONZE,
	SILVER,
	GOLD
}

var coin_quality: int

func _ready():
	var temp = qualities
	print(temp)
	coin_quality = temp["BRONZE"]
	print(coin_quality)
	match coin_quality:
		qualities.BRONZE:
			pass
		qualities.SILVER:
			pass
		qualities.GOLD:
			pass
		

func collect():
	area.monitorable = false
	animator.play("Collected")
	yield(animator,"animation_finished")
	hide()
	yield(get_tree().create_timer(respawn_time),"timeout")
	show()
	area.monitorable = true
	animator.play("Idle")

func _process(delta):
	model.rotate_y(deg2rad(delta + coin_quality))
