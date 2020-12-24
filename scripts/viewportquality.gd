extends Control

func _ready():
	set_render_scale(Settings.render_scale)
	set_shadow_quality(Settings.shadow_quality)

func set_render_scale(scale:float):
	for i in get_child_count():
		get_child(i).stretch_shrink = scale

func set_shadow_quality(quality:int):
	for i in get_child_count():
		get_child(i).get_child(0).shadow_atlas_size = quality
