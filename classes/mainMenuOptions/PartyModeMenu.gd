extends MenuOption

var _isActive: bool = false
const MAX_NUM_PLAYERS: int = 4
const MIN_NUM_PLAYERS: int = 1
var _numPlayers: int = 1


func _init():
	description = "Put your teamwork skills to the test in a game of TETRUS with everyone playing on the same board!"


func onClick() -> bool:
	$AnimationPlayer.play("onClick")
	_isActive = true
	return true


func _startGame() -> void:
	MenuControlsGuide.fadeOut()
	get_node("/root/Main/MusicPlayer").fadeOutCurrentSong()
	var gameScene: PartyModeGame = load("res://classes/PartyModeGame.tscn").instance()
	gameScene.init(_numPlayers)
	get_node("/root/Main").changeScene(gameScene)


func handleInput(ev: InputEvent) -> bool:
	match ev.scancode:
		KEY_UP:
			$MarginContainer/Submenu/UpArrow.frame = 0
			$MarginContainer/Submenu/UpArrow.play("default")
			_numPlayers = int(min(_numPlayers + 1, MAX_NUM_PLAYERS))
			$MarginContainer/Submenu/Players.play(String(_numPlayers) + "p")
		
		KEY_DOWN:
			$MarginContainer/Submenu/DownArrow.frame = 0
			$MarginContainer/Submenu/DownArrow.play("default")
			_numPlayers = int(max(_numPlayers - 1, MIN_NUM_PLAYERS))
			$MarginContainer/Submenu/Players.play(String(_numPlayers) + "p")
		
		KEY_BACKSPACE:
			$AnimationPlayer.play_backwards("onClick")
			SfxPlayerSingleton.playSfx("Cancel")
			return false
		
		KEY_ENTER, KEY_SPACE:
			_startGame()
	
	return true
