extends Node

var player_0_device
var player_1_device

var fullscreen = false
var render_scale: int = 1
var shadow_quality: int = 1

var volume: Array = [
	0.0, 0.0, 0.0,
]

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		fullscreen = not fullscreen
		set_fullscreen(fullscreen)

func set_fullscreen(enabled:bool):
	fullscreen = enabled
	OS.window_fullscreen = fullscreen

