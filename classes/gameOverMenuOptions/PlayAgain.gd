extends MenuOption

func _init():
	description = "Play another game."

func onClick():
	get_node("/root/Main/MusicPlayer").fadeOutCurrentSong()
	yield(find_parent("GameOverPanel").closePanel(), "completed")
	find_parent("PartyModeGame").newGame()
