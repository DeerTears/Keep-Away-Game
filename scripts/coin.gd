extends Spatial

onready var model = $MeshInstance
onready var area = $Area
onready var animator = $AnimationPlayer

export var respawn_time: float = 5.0

enum qualities {
	GARBAGE,
	BRONZE,
	SILVER,
	GOLD
}

var coin_quality: int

func _ready():
	randomize()
	match randi() % qualities.size() - 1:
		0:
			coin_quality = qualities.get("BRONZE")
		1:
			coin_quality = qualities.get("SILVER")
		2:
			coin_quality = qualities.get("GOLD")
	match coin_quality:
		qualities.BRONZE:
			pass
		qualities.SILVER:
			pass
		qualities.GOLD:
			pass
	print(coin_quality)

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
