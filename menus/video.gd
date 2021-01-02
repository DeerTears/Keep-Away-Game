extends Panel

onready var fullscreen_button = $MarginContainer/VBoxContainer/Fullscreen
onready var shadow_slider = $MarginContainer/VBoxContainer/HBox2/ShadowQuality/ShadowQuality
onready var render_scale_slider = $MarginContainer/VBoxContainer/HBox/RenderScale/RenderScale

onready var render_indicator = $MarginContainer/VBoxContainer/HBox/RenderIndicator
onready var shadow_indicator = $MarginContainer/VBoxContainer/HBox2/ShadowIndicator

func _ready():
	fullscreen_button.pressed = Settings.fullscreen
	shadow_slider.value = Settings.shadow_quality
	render_scale_slider.value = Settings.render_scale
	render_indicator.text = "%s" % [render_scale_slider.value]
	shadow_indicator.text = "%s" % [shadow_slider.value]

func _on_Back_pressed():
	get_tree().change_scene("res://menus/settings.tscn")

func _on_Fullscreen_toggled(button_pressed):
	Settings.set_fullscreen(button_pressed)
	pass # Replace with function body.

func _on_RenderScale_value_changed(value):
	Settings.render_scale = value
	render_indicator.text = "%s" % [render_scale_slider.value]

func _on_ShadowQuality_value_changed(value):
	Settings.shadow_quality = value
	shadow_indicator.text = "%s" % [shadow_slider.value]

func _on_DebugTrails_toggled(button_pressed):
	GameInfo.start_with_debug_trails = button_pressed
