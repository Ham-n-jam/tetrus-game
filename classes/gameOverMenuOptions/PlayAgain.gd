extends MenuOption

func _init():
	description = "Play another game."

func onClick():
	find_parent("GameOverPanel").closePanel()
	find_parent("PartyModeGame").newGame()
