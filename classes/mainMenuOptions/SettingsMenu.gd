extends MenuController

func _init():
	description = "Adjust settings such as the player controls and volume mix."

func onClick():
	$AnimationPlayer.play("onClick")
	startUpMenu("vertical")
	_isActive = true
	$MarginContainer/Submenu/Options/MasterVol.loadVolume()
	$MarginContainer/Submenu/Options/BGMVol.loadVolume()
	$MarginContainer/Submenu/Options/SFXVol.loadVolume()
	return true
