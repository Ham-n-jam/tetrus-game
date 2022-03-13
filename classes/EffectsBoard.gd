extends MarginContainer

class_name EffectsBoard

const CELL_CLEAR_VAL: int = 0
const CELL_OOB_VAL: int = -1

var _numRows: int
var _numCols: int
var _blockSize: int
var _numInvisibleCells: int
var _prevGhostShapePosDict: Dictionary # Key: PlayerInt, Val: [Vector2 position, ShapeState2DArray]
var _playerColoursDict: Dictionary # Key: PlayerInt, Val: Color
var _rng = RandomNumberGenerator.new()
var _ghostBoardType: bool

func init(numCols: int=10, numRows: int=20, blockSize: int=16, numInvisibleCells: int=3, ghostBoardType: bool=false) -> void:
	_numRows = numRows
	_numCols = numCols
	_blockSize = blockSize
	_numInvisibleCells = numInvisibleCells
	_ghostBoardType = ghostBoardType
	
	# Read in saved player colours json, converting from hex String to Color
	var coloursDict: Dictionary = GlobalFunc.loadJson("res://saveData/playerColours.json")
	for player in coloursDict:
		var colourHex = coloursDict[player]
		_playerColoursDict[player] = Color(colourHex) 
	
	# Set num cols
	$GridContainer.set("columns", _numCols)
	
	# Set spacing between cells to zero
	$GridContainer.set("custom_constants/hseparation", 0)
	$GridContainer.set("custom_constants/vseparation", 0)
	
	# Populate board with EffectBlocks
	var i: int = 0
	while i < (_numRows * _numCols):
		var eb: EffectBlock = load("res://classes/EffectBlock.tscn").instance()
		$GridContainer.add_child(eb)
		i += 1
	


# Create 2D array to be accessed array[y][x]
func _create_2d_array(width: int, height: int, value):
	var a = []
	for y in range(height):
		a.append([])
		a[y].resize(width)
		for x in range(width):
			a[y][x] = value

	return a


func setBoardCellToEmpty(row: int, col: int):
	if !(row < 0 or col < 0 or row >= _numRows or col >= _numCols):
		var cell: EffectBlock = _getChildCell(row, col)
		if cell:
			cell.playAnimation("empty")


func setBoardCellToAnimation(row: int, col: int, animation: String, colour: Color=Color.white):
	if !(row < 0 or col < 0 or row >= _numRows or col >= _numCols):
		var cell: EffectBlock = _getChildCell(row, col)
		if cell:
			# Change out the palette on the block
			cell.playAnimation(animation, colour)


# Get child cell in a certain col/row
func _getChildCell(row: int, col: int) -> EffectBlock:
	if (row >= 0):
		var childIndex = _numCols * row + col
		return $GridContainer.get_children()[childIndex]
	return null


func handle_updated_ghost_shape(player: int, shapeState2DArray: Array, shapePosition: Vector2) -> void:
	if _prevGhostShapePosDict.has(player):
		var prevStateArr = _prevGhostShapePosDict[player][0] # Array format shapeState2DArray, shapePosition
		var prevPos = _prevGhostShapePosDict[player][1]
		
		# Check if a redraw is actually required
		if prevStateArr != shapeState2DArray or prevPos != shapePosition:
			for row in range(0, prevStateArr.size()):
				for col in range(0, prevStateArr[row].size()):
					if prevStateArr[row][col] != CELL_CLEAR_VAL:
						var rowVal = row + prevPos[0] - _numInvisibleCells
						setBoardCellToEmpty(rowVal, col + prevPos[1])
	
	for row in range(0, shapeState2DArray.size()):
		for col in range(0, shapeState2DArray[row].size()):
			if shapeState2DArray[row][col] != CELL_CLEAR_VAL:
				var rowVal = row + shapePosition[0] - _numInvisibleCells
				setBoardCellToAnimation(rowVal, col + shapePosition[1], "16outline", _playerColoursDict[String(player)])
	
	_prevGhostShapePosDict[player] = [shapeState2DArray, shapePosition]


func handle_lines_cleared(indiciesRowsCleared: Array):
	for row in indiciesRowsCleared:
		row = row - _numInvisibleCells
		for col in range(0, _numCols):
			_getChildCell(row, col).doExplosion()


func handle_game_over(_score, _linesCleared):
	if _ghostBoardType:
		for effectBl in $GridContainer.get_children():
			effectBl.playAnimation("empty")
	else:
		for _i in range(0, 80):
			$GameOverTimer.start()
			_rng.randomize()
			_getChildCell(_rng.randi_range(0, _numRows - 1), _rng.randi_range(0, _numCols - 1)).doExplosion()
			yield($GameOverTimer, "timeout")
		
		handle_pause()


func handle_pause():
	# Animation fill out from middle outwards
	var midRowIdx: int = _numRows / 2
	var midColIdx: int = _numCols / 2
	
	for i in range(0, _numRows / 2 + 1):
		for j in range(0, _numCols / 2 + 1):
			$PauseAnimationTimer.start()
			if midRowIdx - i >= 0 and midColIdx - j >= 0:
				_getChildCell(midRowIdx - i, midColIdx - j).doPause()
			if midRowIdx + i < _numRows and midColIdx - j >= 0:
				_getChildCell(midRowIdx + i, midColIdx - j).doPause()
			if midRowIdx - i >= 0 and midColIdx + j < _numCols:
				_getChildCell(midRowIdx - i, midColIdx + j).doPause()
			if midRowIdx + i < _numRows and midColIdx + j < _numCols:
				_getChildCell(midRowIdx + i, midColIdx + j).doPause()
			yield($PauseAnimationTimer, "timeout")


func handle_unpause():
	# Play same animation on all effect blocks simultaneously
	for i in range(0, _numRows):
		for j in range(0, _numCols):
				_getChildCell(i, j).doUnpause()
