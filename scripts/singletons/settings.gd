extends Node

const save_path = "user://settings.json"

var player_0_device
var player_1_device

var fullscreen = false
var render_scale: int = 1
var shadow_quality: int = 1

var volume: Array = [
	0.0, 0.0, 0.0,
]

func _ready():
	load_settings()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		fullscreen = not fullscreen
		set_fullscreen(fullscreen)

func set_fullscreen(enabled:bool):
	fullscreen = enabled
	OS.window_fullscreen = fullscreen
	save_settings()

func save_settings():
	var save_file = File.new()
	save_file.open(save_path, File.WRITE)
	var settings_dictionary = {
		"fullscreen" : fullscreen,
		"volume" : volume,
		"shadow_quality" : shadow_quality
	}
	save_file.store_line(to_json(settings_dictionary))
	save_file.close()

func load_settings():
	var save_file = File.new()
	if not save_file.file_exists(save_path):
		return
	save_file.open(save_path, File.READ)
	var settings_dictionary = {}
	var raw_data = save_file.get_as_text()
	settings_dictionary = parse_json(raw_data)
	save_file.close()
	set_fullscreen(settings_dictionary["fullscreen"])
	volume = settings_dictionary["volume"]
	update_volume(settings_dictionary["volume"])
	shadow_quality = settings_dictionary["shadow_quality"]

func update_volume(_volume):
	AudioServer.set_bus_volume_db(0, _volume[0])
	AudioServer.set_bus_volume_db(1, _volume[1])
	AudioServer.set_bus_volume_db(2, _volume[2])
