extends MenuOption

func _init():
	description = "Go back to the main menu."

func onClick():
	var titleScene = load("res://classes/TitleScreen.tscn").instance()
	get_node("/root/Main").changeScene(titleScene)
