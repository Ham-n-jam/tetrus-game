extends Control



func _ready() -> void:
	get_node("/root/Main/MusicPlayer").playNewSong("stardreamerSkip")
	
	$Timer.start()
	yield($Timer, "timeout")
	
	# Pop in logo then move it up
	$Logo.play("default")
	yield($Logo, "animation_finished")
	$Tween.interpolate_property($Logo, "position:y", null, $Logo.position.y - 100, 1.5, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	# Fade in name and menu
	$Tween.interpolate_property($Alex, "modulate:a", 0, 255, 6, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MainMenu, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	$MainMenu.startUpMenu("horizontal")
	
