extends MenuOption

func _init():
	description = "Exit the game."

func onClick():
	get_tree().quit()
