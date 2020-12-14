extends Spatial

# refactor: simplify so this script can be removed
# any time this script/node is referenced, have the calling object find this node, go one level deeper to the kinematicbody, and call the body instead

onready var kinematic = $KinematicBody
onready var model = $KinematicBody/MeshInstance
export var player_number: int = 0

var detected_devices = [
	InputEventMouseMotion,
	InputEventJoypadMotion,
]

func _ready():
	# refactor: simplify, either mouse or joypad, this is a 2-player game
	kinematic.controlling_player = player_number # todo: test with Joypads
	kinematic.look_device = detected_devices[player_number]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_player_number(number:int):
	# refactor: simplify, either mouse or joypad
	player_number = number
	kinematic.controlling_player = number

func disable_input():
	kinematic.movement_enabled = false

func enable_input():
	kinematic.movement_enabled = true
