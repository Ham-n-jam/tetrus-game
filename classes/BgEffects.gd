extends Node

onready var tween = $Tween
onready var kaleidoscopeMaterial = $Bg2/Kaleidoscope.get_material()

func doBgSwirlEffect() -> void:
	tween.interpolate_property(kaleidoscopeMaterial, "shader_param/palette_speed", 0.05, 0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
