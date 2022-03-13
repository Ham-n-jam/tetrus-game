extends Node


func _ready():
	for i in range(AudioServer.bus_count):
		AudioServer.set_bus_volume_db(i, linear2db(7/20.0))


func playNewSong(songName: String):
	var nextSong = load("res://assets/bgm/" + songName + ".ogg")
	$Bgm.stream = nextSong
	$Bgm.volume_db = 0
	$Bgm.play()


func fadeOutCurrentSong():
	$Tween.interpolate_property($Bgm, "volume_db", null, -80, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func fadeToNextSong(songName: String):
	fadeOutCurrentSong()
	yield($Tween, "tween_completed")
	playNewSong(songName)
