extends MenuOption

func _init():
	description = "Play another game."

func onClick():
	get_node("/root/Main/MusicPlayer").fadeOutCurrentSong()
	find_parent("GameOverPanel").closePanel()
	find_parent("PartyModeGame").newGame()
