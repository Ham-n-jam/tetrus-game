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

func init(numCols: int=10, numRows: int=20, blockSize: int=16, numInvisibleCells: int=3) -> void:
	_numRows = numRows
	_numCols = numCols
	_blockSize = blockSize
	_numInvisibleCells = numInvisibleCells
	
	# Read in saved player colours json, converting from hex String to Color
	var coloursDict: Dictionary = _loadJson("res://saveData/playerColours.json")
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


func setBoardCellToColour(row: int, col: int, colour: Color):
	var cell: EffectBlock = _getChildCell(row, col)
	if cell:
		# Change out the palette on the block
		cell.setColour(colour)


func setBoardCellToEmpty(row: int, col: int):
	if !(row < 0 or col < 0 or row >= _numRows or col >= _numCols):
		var cell: EffectBlock = _getChildCell(row, col)
		if cell:
			cell.playAnimation("empty")


func setBoardCellToAnimation(row: int, col: int, animation: String):
	if !(row < 0 or col < 0 or row >= _numRows or col >= _numCols):
		var cell: EffectBlock = _getChildCell(row, col)
		if cell:
			# Change out the palette on the block
			cell.playAnimation(animation)


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
				setBoardCellToColour(rowVal, col + shapePosition[1], _playerColoursDict[String(player)])
				setBoardCellToAnimation(rowVal, col + shapePosition[1], "16outline")
	
	_prevGhostShapePosDict[player] = [shapeState2DArray, shapePosition]


func _loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict