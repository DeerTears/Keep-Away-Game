extends Spatial

# this script handles recieving group calls, input device changes, and updating the hud when appropriate

onready var kinematic = $KinematicBody
onready var model = $KinematicBody/MeshInstance
onready var hud = $HUD
onready var debug_particles = $KinematicBody/Particles

export var player_number: int = 0

var debug: bool = false

var detected_devices = [
	InputEventMouseMotion,
	InputEventJoypadMotion,
]

func _ready():
	# refactor: simplify, either mouse or joypad, this is a 2-player game
	kinematic.player_number = player_number # todo: test with Joypads
	kinematic.look_device = detected_devices[player_number]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	kinematic.connect("score_changed",self,"change_score")


func _input(event):
	if event.is_action_released("toggle_debug"):
		debug = not debug
		debug_particles.visible = debug

func change_score(amount:int): # refactor: unify "change" vs. "set"
	GameInfo.add_score(player_number, amount)
	hud.update_score(GameInfo.p0_score)

func reset_score_label():
	hud.update_score(0)

func enable_movement(_true:bool):
	kinematic.movement_enabled = _true

func respawn():
	var target = GameInfo.get_my_respawn_location(player_number)
	kinematic.teleport(target, false)

func show_notice(notice_type:int):
	hud.show_notice(notice_type)

func update_player_number(number:int):
	# refactor: simplify, either mouse or joypad
	player_number = number
	kinematic.player_number = number
