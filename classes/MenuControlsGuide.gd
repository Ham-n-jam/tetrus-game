extends Node2D

onready var _tween = $Tween


func fadeIn() -> void:
	if modulate != Color(1,1,1,1):
		_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
		_tween.start()
		yield(_tween, "tween_completed")


func fadeOut() -> void:
	_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween, "tween_completed")
