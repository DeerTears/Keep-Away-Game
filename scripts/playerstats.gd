extends Spatial

# this script handles recieving group calls, input device changes, and updating the hud when appropriate
var fps_camera: bool = true

onready var kinematic = $KinematicBody
onready var model = $KinematicBody/MeshInstance
onready var hud = $HUD
onready var debug_particles = $KinematicBody/Particles

export var player_number: int = 0

var debug: bool = false

var devices_in_use = [
	InputEventMouseMotion,
	InputEventJoypadMotion,
]

func _ready():
	kinematic.player_number = player_number
	kinematic.look_device = devices_in_use[player_number]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	kinematic.connect("score_changed",self,"change_score")

func _input(event):
	if event.is_action_released("toggle_debug"):
		debug = not debug
		set_debug_trails(debug)

func set_debug_trails(enabled:bool):
	debug_particles.visible = enabled

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
	player_number = number
	kinematic.player_number = number

func update_devices_in_use(dict:Dictionary):
	devices_in_use = dict
