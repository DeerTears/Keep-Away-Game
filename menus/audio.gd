extends Panel

onready var indicator = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Indicator
onready var slider = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/VSlider

func _ready():
	indicator.text = "%sdb" % [slider.value]

func _on_VSlider_value_changed(value):
	indicator.text = "%sdb" % [value]
	AudioServer.set_bus_volume_db(0, value)
	if $Test.is_playing():
		return
	$Test.play()

func _on_Button_pressed():
	get_tree().change_scene("res://menus/settings.tscn")
