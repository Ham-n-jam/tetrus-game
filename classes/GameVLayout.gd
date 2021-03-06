extends CenterContainer

class_name GameVLayout

const NUM_NEXT_SHAPES: int = 6

var _boardContainer: MarginContainer
var _playerHoldBoardDict: Dictionary # Key: playerInt, Val: Board
var _next: InfoVBox
var _nextBoards: Array # Array[ShapePreviewBoard]
var _lines: InfoVBox
var _linesLabel: Label
var _board: Board
var _score: InfoVBox
var _scoreLabel: Label
var _level: InfoVBox
var _levelLabel: Label
var _playersArray: Array # Array of playerInt, starting at 1
onready var _animationPlayer = $AnimationPlayer

enum _shapeTypes {O, T, S, Z, L, J, I}

func init(numPlayers:int, blockSize: int=16, numCols: int=10, numRows: int=20, previewBlockSize: int=10):
	_boardContainer = $HBoxContainer/GameBoard/BoardContainer
	_next = $HBoxContainer/TopVBox/Control/Next
	_lines = $HBoxContainer/TopVBox/BottomVBox/Control2/Lines
	_score = $HBoxContainer/TopVBox/BottomVBox/Control3/Score
	_level = $HBoxContainer/TopVBox/BottomVBox/Control/Level
	_board = $HBoxContainer/GameBoard/BoardContainer/BlocksBoard
	$HBoxContainer/GameBoard.init(blockSize, numCols, numRows)
	_playersArray = range(1, numPlayers + 1)
	
	for player in _playersArray:
		var playerInfo: PlayerGameInfo = load("res://classes/PlayerGameInfo.tscn").instance()
		playerInfo.init(player)
		
		# Initialise the hold shape GUI
		var holdBgAndBoard: Array = createPreviewBlockWBg(previewBlockSize)
		playerInfo.setHoldBoard(holdBgAndBoard)
		_playerHoldBoardDict[player] = holdBgAndBoard[1]
		$HBoxContainer/PlayerInfoVBox.add_child(playerInfo)
	
	# Setup InfoVBoxes
	_next.setLabelText("NEXT")
	_lines.setLabelText("LINES")
	_score.setLabelText("SCORE")
	_level.setLabelText("LEVEL")
	
	# Initialise the stats GUI
	var boldFont: DynamicFont = DynamicFont.new()
	boldFont.font_data = load("res://assets/fonts/bold.ttf")
	boldFont.size = 8
	
	var linesLabel: Label = Label.new()
	linesLabel.add_font_override("font", boldFont)
	_linesLabel = linesLabel
	_lines.setContentChildren([linesLabel])
	
	var scoreLabel: Label = Label.new()
	scoreLabel.add_font_override("font", boldFont)
	_scoreLabel = scoreLabel
	_score.setContentChildren([scoreLabel])
	
	var levelLabel: Label = Label.new()
	levelLabel.add_font_override("font", boldFont)
	_levelLabel = levelLabel
	_level.setContentChildren([levelLabel])
	
	# Initialise the next shapes GUI
	var nextVBox: VBoxContainer = VBoxContainer.new()
	nextVBox.set("custom_constants/separation", 8)
	for i in range(0, NUM_NEXT_SHAPES):
		var cc: CenterContainer = CenterContainer.new()
		var preview = createPreviewBlockWBg(previewBlockSize)
		cc.add_child(preview[0]) # bg
		cc.add_child(preview[1]) # board
		_nextBoards.append(preview[1])
		
		nextVBox.add_child(cc)
	_next.setContentChildren([nextVBox])
	
	# Use clean state defaults
	_cleanSlate()


# Create a preview shape grid with a background
func createPreviewBlockWBg(previewBlockSize: int) -> Array:
	var pbgBlock: TextureRect = TextureRect.new()
	var loadPbgBlock: String = "res://assets/sprites/%spbgblock.png" % String(previewBlockSize)
	pbgBlock.texture = load(loadPbgBlock)
	var pbgBoard: Board = load("res://classes/Board.tscn").instance()
	pbgBoard.init(pbgBlock, 4, 2)

	var block: TextureRect = TextureRect.new()
	var loadBlock: String = "res://assets/sprites/%sblock.png" % String(previewBlockSize)
	block.texture = load(loadBlock)
	block.modulate.a = 0
	var previewGrid: Board = load("res://classes/Board.tscn").instance()
	previewGrid.init(block, 4, 2)
	
	return [pbgBoard, previewGrid]


# Reset GUI data
func _cleanSlate() -> void:
	_linesLabel.text = "0"
	_scoreLabel.text = "0"
	_levelLabel.text = "1"
	for player in _playersArray:
		_playerHoldBoardDict[player].clearBoard()
	for board in _nextBoards:
		board.clearBoard()


func prepareNewGame():
	_animationPlayer.play("newGame")


func handle_hold_shape_changed(player: int, newShape: String):
	var shapeDataFactory: ShapeDataFactory = ShapeDataFactory.new()
	_playerHoldBoardDict[player].transitionToNextStateArray(shapeDataFactory.getShapePreview2DArray(newShape), shapeDataFactory.getShapeMaterial(newShape), true)


func handle_next_shapes_changed(nextShapes: Array):
	for i in range(0, NUM_NEXT_SHAPES):
		var shapeDataFactory: ShapeDataFactory = ShapeDataFactory.new()
		_nextBoards[i].transitionToNextStateArray(shapeDataFactory.getShapePreview2DArray(nextShapes[i]), shapeDataFactory.getShapeMaterial(nextShapes[i]))


func _setLinesClearedLabel(lines: float):
	_linesLabel.text = String(int(ceil(lines)))


func handle_lines_cleared_changed(lines: int):
	var tween: Tween = $LinesClearedTween
	tween.interpolate_method(self, "_setLinesClearedLabel", int(_linesLabel.get_text()), lines, 0.5)
	tween.start()


func handle_new_game():
	_cleanSlate()


func _setScoreLabel(score: float):
	_scoreLabel.text = String(int(ceil(score)))


func handle_score_changed(score: int):
	var tween: Tween = $LinesClearedTween
	tween.interpolate_method(self, "_setScoreLabel", int(_scoreLabel.get_text()), score, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func handle_level_changed(level: int):
	_levelLabel.text = String(level)


func handle_game_over(_score, _linesCleared):
	for i in range(0, _nextBoards.size()):
		_nextBoards[i].handle_game_over()
	
	for player in _playerHoldBoardDict:
		_playerHoldBoardDict[player].handle_game_over()
	
	_animationPlayer.play("gameOver")
