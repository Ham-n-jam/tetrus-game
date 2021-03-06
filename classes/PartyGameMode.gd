extends Control

class_name PartyModeGame

var _numRows: int
var _numCols: int
var _blockSize: int = 16
var _numPlayers: int


# 1-4 player game
func init(numPlayers: int) -> void:
	_numPlayers = numPlayers


func _ready() -> void:
	match _numPlayers:
		1:
			_numRows = 10
			_numCols = 20
		
		2:
			_numRows = 12
			_numCols = 20
		
		3:
			_numRows = 14
			_numCols = 20
		
		4:
			_numRows = 20
			_numCols = 20
	
	$GameVLayout.init(_numPlayers, _blockSize, _numRows, _numCols)
	$Gameplay.init($GameVLayout._board, _numPlayers)
	
	# Connect gameplay changes to the GUI
	$Gameplay.connect("hold_shape_changed", $GameVLayout, "handle_hold_shape_changed")
	$Gameplay.connect("next_shapes_changed", $GameVLayout, "handle_next_shapes_changed")
	$Gameplay.connect("lines_cleared_changed", $GameVLayout, "handle_lines_cleared_changed")
	$Gameplay.connect("score_changed", $GameVLayout, "handle_score_changed")
	$Gameplay.connect("level_changed", $GameVLayout, "handle_level_changed")
	$Gameplay.connect("new_game", $GameVLayout, "handle_new_game")
	$Gameplay.connect("game_over", find_node("GhostBoard"), "handle_game_over")
	$Gameplay.connect("updated_ghost_shape", find_node("GhostBoard"), "handle_updated_ghost_shape")
	$Gameplay.connect("lines_cleared", find_node("EffectsBoard"), "handle_lines_cleared")
	$Gameplay.connect("game_over", find_node("EffectsBoard"), "handle_game_over")
	$Gameplay.connect("game_over", self, "handle_game_over")
	$Gameplay.connect("game_over", $GameVLayout, "handle_game_over")
	
	# Hook up the controls to the gameplay functions
	$GameplayControls.init(_numPlayers, $Gameplay)
	newGame()


func newGame():
	var effectsBoard = find_node("EffectsBoard")
	
	effectsBoard.handle_unpause()
	$GameVLayout.prepareNewGame()
	yield(find_node("Countdown").doCountdown(), "completed")
	get_node("/root/Main/MusicPlayer").playNewSong("korobeiniki")
	$Gameplay.newGame()


func handle_game_over(score: int, lines: int):
	get_node("/root/Main/MusicPlayer").fadeToNextSong("gameOver")
	yield(find_node("GameOverPanel").doGameOver(score, lines), "completed")
