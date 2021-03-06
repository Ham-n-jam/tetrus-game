extends Control

class_name Board

const SHADER: Shader = preload("res://assets/palettes/uv_pallete.shader")
const CELL_CLEAR_VAL: int = 0
const CELL_OOB_VAL: int = -1

var _numRows: int
var _numCols: int
var _block
var _boardStateArray: Array setget setBoardStateArray, getBoardStateArray
var _num_invisible_rows: int
var _transStateArray: Array
var _transShapeMaterial: ShaderMaterial


func init(block, numCols: int=10, numRows: int=20, numInvisibleRows: int=0) -> void:
	_numRows = numRows
	_numCols = numCols
	_block = block
	_num_invisible_rows = numInvisibleRows
	
	# Set num cols
	$GridContainer.set("columns", _numCols)
	
	# Set spacing between cells to zero
	$GridContainer.set("custom_constants/hseparation", 0)
	$GridContainer.set("custom_constants/vseparation", 0)
	
	_add_blocks(_block)
	_boardStateArray = _create_2d_array(numCols, numRows + _num_invisible_rows, CELL_CLEAR_VAL)


# Fill this Board with blocks
func _add_blocks(block) -> void:
	var i: int = 0
	while i < (_numRows * _numCols):
		$GridContainer.add_child(block.duplicate())

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


func getBoardStateArray() -> Array:
	return _boardStateArray.duplicate(true)


func setBoardStateArray(newStateArray: Array) -> void:
	_boardStateArray = newStateArray


# Sets a board GUI cell to a certain colour and the _boardStateArray to a player number
func setBoardCellToColour(row: int, col: int, material: ShaderMaterial, playerNum: int=1) -> void:
	if !(row < 0 or col < 0 or row >= _boardStateArray.size() or col >= _numCols):
		_boardStateArray[row][col] = playerNum
		# Do offset for GUI
		setBoardCellGuiToColour(row, col, material)


func setBoardCellGuiToColour(row: int, col: int, material: ShaderMaterial):
		var cell = _getChildCell(row, col)
		if cell:
			# Change out the palette on the block
			cell.set_material(material)
			cell.modulate.a = 1


# Return cell value, or -1 if the row/col is invalid
func getCellVal(row: int, col: int) -> int:
	if (row < 0 or col < 0 or row >= _boardStateArray.size() or col >= _numCols):
		return CELL_OOB_VAL
	return _boardStateArray[row][col]


func setBoardCellToEmpty(row: int, col: int):
	if !(row < 0 or col < 0 or row >= _boardStateArray.size() or col >= _numCols):
		_boardStateArray[row][col] = CELL_CLEAR_VAL
		var cell = _getChildCell(row, col)
		if cell:
			cell.modulate.a = 0


# Get child cell in a certain col/row
func _getChildCell(row: int, col: int):
	if (row - _num_invisible_rows >= 0):
		var childIndex = _numCols * (row - _num_invisible_rows) + col
		return $GridContainer.get_children()[childIndex]
	return null


func setColourOfAllActiveCells(material: ShaderMaterial) -> void:
	clearBoardGUI()
	for row in range(0, len(_boardStateArray)):
		for col in range(0, len(_boardStateArray[row])):
			if _boardStateArray[row][col] != CELL_CLEAR_VAL:
				setBoardCellToColour(row, col, material, _boardStateArray[row][col])


func clearBoardGUI() -> void:
	# Set all cells blank
	for cell in $GridContainer.get_children():
		cell.modulate.a = 0


func clearBoardState() -> void:
	# Reset state array
	for row in range(0, _boardStateArray.size()):
		for col in range(0, _boardStateArray[row].size()):
			_boardStateArray[row][col] = CELL_CLEAR_VAL


func clearBoard() -> void:
	clearBoardGUI()
	clearBoardState()


func _clearGuiRow(row: int) -> void:
	# For every cell in the row, move it to the top of the array and clear it
	for _i in range(0, _numCols):
		# Get the end cell of the row
		var cell = _getChildCell(row, _numCols - 1)
		cell.modulate.a = 0
		# Moving to child position 0 means next iteration the next cell will be at the end
		$GridContainer.move_child(cell, 0)


# Returns indexes of full rows
func checkForFullRows() -> Array:
	var indiciesOfFullRows: Array = []
	
	# Check for full rows
	for i in range(0, _boardStateArray.size()):
		# If row doesn't have a clear cell
		if (!_boardStateArray[i].has(CELL_CLEAR_VAL)):
			indiciesOfFullRows.append(i)
	
	return indiciesOfFullRows


# Returns indexes of rows cleared
func clearAnyFullRows():
	var indiciesOfFullRows: Array = checkForFullRows()
	
	if (indiciesOfFullRows.size() > 0):
		# For each full row, move all rows above down
		for i in range(0, indiciesOfFullRows.size()):			
			# - i accounts for removal of items index-shift
			_boardStateArray.remove(indiciesOfFullRows[i] - i)
		# Append empty rows to the top of the array
		var fillerArray: Array = _create_2d_array(_numCols, indiciesOfFullRows.size(), CELL_CLEAR_VAL)
		_boardStateArray = fillerArray + _boardStateArray
		
		for row in indiciesOfFullRows:
			_clearGuiRow(row)


func _moveTopGuiRowToBottomAndClear() -> void:
	# For every cell in the row, move it to the top of the array and clear it
	for _i in range(0, _numCols):
		# Get the first cell of the row
		var cell = _getChildCell(_num_invisible_rows, 0)
		cell.modulate.a = 0
		# Move to end child position
		$GridContainer.move_child(cell, $GridContainer.get_child_count() - 1)


# Animated transition upwards from the current state to the new state (newStateArray must be same width)
func transitionToNextStateArray(newStateArray: Array, newMaterial: ShaderMaterial, emptyBufferRow: bool=false):
	_boardStateArray = newStateArray.duplicate(true)
	_transStateArray = []
	if (emptyBufferRow):
		_transStateArray += _create_2d_array(_numCols, 1, CELL_CLEAR_VAL)
	_transStateArray += newStateArray.duplicate(true)
	_transShapeMaterial = newMaterial
	
	# Do an initial transition animation frame
	_on_TransTimer_timeout()
	
	$TransTimer.start()


func handle_game_over():
	for _i in range(0, _numRows + 1):
		$GameOverTimer.start()
		_clearGuiRow(_numRows + _num_invisible_rows - 1)
		yield($GameOverTimer, "timeout")
	clearBoardState()


func _on_TransTimer_timeout() -> void:
	if (_transStateArray.size() > 0):
		_moveTopGuiRowToBottomAndClear()
		
		# Add the next row of the _transStateArray to the GUI
		var nextRow: Array = _transStateArray[0]
		_transStateArray.remove(0)
		
		# Add to last row of GUI
		for i in range(0, nextRow.size()):
			if nextRow[i] != CELL_CLEAR_VAL:
				setBoardCellGuiToColour(_numRows-1, i, _transShapeMaterial)
		
		
	# Stop transitioning if all of the transition shape is now in the GUI
	if (_transStateArray.size() <= 0):
		$TransTimer.stop()
