extends Node

class_name Gameplay

signal hold_shape_changed(player, newShape)
signal next_shapes_changed(nextShapesArray)
signal lines_cleared_changed(numLinesCleared)
signal score_changed(score)
signal level_changed(level)
signal new_game()
signal updated_ghost_shape(player, shapeState2DArray, shapePosition)
signal lines_cleared(indiciesRowsCleared)
signal game_over(score, lines)

const MAX_LEVEL: int = 16
const TICK_SPEED = 1.0
const FAST_MULTIPLE = 10
const WAIT_TIME = 0.15
const REPEAT_DELAY = 0.05
const NUM_NEXT_SHAPES: int = 14
const CELL_CLEAR_VAL: int = 0
const LOCK_DELAY_SECS: float = 0.5
const RESERVED_NUM_OFFSET: int = 1
const CELL_LOCKED_IN_VAL: int = 1
const LOCK_IN_SECS: float = 0.1
const CELL_OOB_VAL: int = -1

enum _shapeTypes {O, T, S, Z, L, J, I}
enum _rotDirection {LEFT, RIGHT}
enum _StateEnum {NOT_ON_BOARD, STALLED, FALLING, CHECK, LOCKED_IN, LOCK_DELAY}
enum _GravityResultEnum {MOVED, STALLED, LOCK_DELAY, CHECK, PLACED}

var _shapeDataFactory = load("res://classes/ShapeDataFactory.gd").new()
var _currentShapeDict: Dictionary # Key: playerInt, Val: ShapeData
var _holdShapeDict: Dictionary # Key: playerInt, Val: String
var _alreadyDidHoldDict: Dictionary # Key: playerInt, Val: bool
var _nextShapes: Array # Array of ShapeData
var _playerControlsDict: Dictionary # Key: playerInt, Val: controlsDict
var _spawnLocationDict: Dictionary # Key: playerInt, val: spawnColInt
var _playerLockDelayTimerDict: Dictionary # Key: playerInt, val: Timer
var _wallkickDataDict: Dictionary # Key: shapeWallkickType, val: Dictionary(Key: 0>>1 etc, val: Array like Vector2)
var _playerLockedInTimerDict: Dictionary # Key: playerInt, val: Timer
var _board: Board
var _score: int
var _level: int
var _linesCleared: int
var _numPlayers: int
var _playersArray: Array # Array of playerInt, starting at 1
var _gameHasStarted: bool = false # Is there a game at the moment
var _gameIsPlaying: bool = false # Is the game playing or paused


# Make sure the _numCols in the board is at least numPlayers * 4
func init(board: Board, numPlayers: int=1):
	_board = board
	_numPlayers = numPlayers
	# Create array of all player numbers (indexing from 1)
	_playersArray = range(1, numPlayers + 1)
	
	# Try to divide the board into equal 4-wide locations for spawns
	var playerSpace: int = _board._numCols / numPlayers
	for player in _playersArray:
		# Set spawn to be the center of the playerspace
		var spawnCol: int = playerSpace * (player - 1) + (playerSpace / 2 - 2)
		_spawnLocationDict[player] = spawnCol
	
	_wallkickDataDict = GlobalFunc.loadJson("res://assets/dataJson/wallkick_data.json")
	
	# Add lock delay timers for each player
	for player in _playersArray:
		var lockDelayTimer = Timer.new()
		add_child(lockDelayTimer)
		lockDelayTimer.set_one_shot(true)
		lockDelayTimer.set_wait_time(LOCK_DELAY_SECS)
		lockDelayTimer.connect("timeout", self, "_on_player_lock_delay_timeout", [player])
		_playerLockDelayTimerDict[player] = lockDelayTimer

		var lockedInTimer = Timer.new()
		add_child(lockedInTimer)
		lockedInTimer.set_one_shot(true)
		lockedInTimer.set_wait_time(LOCK_IN_SECS)
		lockedInTimer.connect("timeout", self, "_on_player_lock_in_timeout", [player])
		_playerLockedInTimerDict[player] = lockedInTimer


func restartBoardTicker() -> void:
	$BoardTicker.start()


func newGame() -> void:
	_gameHasStarted = true
	_gameIsPlaying = true
	emit_signal("new_game")
	randomize()
	
	# Clear elements
	_board.clearBoard()
	
	for player in _playersArray:
		_currentShapeDict[player] = null
		_holdShapeDict[player] = ""
		_alreadyDidHoldDict[player] = false
	
	# Reset variables
	_score = 0
	_level = 1
	_setTickerSpeedBasedOnLevel()
	_linesCleared = 0
	_nextShapes.clear()
	# Start with 14 blocks in the queue
	_nextShapes += generateNext7Array()
	_nextShapes += generateNext7Array()
	
	# Start board ticker which syncs every player's block falling
	restartBoardTicker()
	
	
	# Start all players off with a shape
	for player in _playersArray:
		nextShape(player)


func nextShape(player: int, specificNextShape: String="") -> void:
	var shape: ShapeData
	if (specificNextShape == ""):
		# Get next shape from queue
		shape = _shapeDataFactory.getShapeData(_nextShapes[0])
		_nextShapes.remove(0)
		emit_signal("next_shapes_changed", _nextShapes.duplicate(true))
	else:
		# Use the input shape
		shape = _shapeDataFactory.getShapeData(specificNextShape)
	_currentShapeDict[player] = shape
	
	# Make sure _nextShapes is topped up
	if _nextShapes.size() < NUM_NEXT_SHAPES:
		_nextShapes += generateNext7Array()
	
	# Set position of shape to spawn location for the player, offsetting for O shape
	if (shape._shapeType == "O"):
		shape._position = Vector2(0, _spawnLocationDict[player] + 1)
	else:
		shape._position = Vector2(0, _spawnLocationDict[player])
	
	# Try to place the shape on the board in the spawn area
	if(!attemptPlace(player)):
		# If failed, game over
		gameOver()
		return
	else:
		 # Move block down twice to get it on-screen
		attemptGravity(player)
		attemptGravity(player)


func attemptHold(player: int) -> bool:
	if (_currentShapeDict[player] == null):
		return false
	
	if (_alreadyDidHoldDict[player]):
		# Player already used a hold this cycle
		return false
	else:
		_alreadyDidHoldDict[player] = true
		var heldShape: String =  _holdShapeDict[player]
		var shape: ShapeData = _currentShapeDict[player]
		_holdShapeDict[player] = shape._shapeType
		emit_signal("hold_shape_changed", player, shape._shapeType)
		_removeShapeFromBoard(shape)
		if (heldShape == ""):
			# First time using HOLD this game, just bring out the next shape
			nextShape(player)
		else:
			# Switch out the current shape and held shape
			nextShape(player, heldShape)
		
		return true


func attemptPlace(player: int) -> bool:
	var shape: ShapeData = _currentShapeDict[player]
	if (shape == null):
		return false
	
	# If space is free, place the shape on the board
	if _checkValidMove(shape.getArray(), (shape._position)):
		_addShapeToBoard(shape, player)
		shape._state = _StateEnum.FALLING
		return true
	else:
		return false


func attemptMoveLeft(player: int) -> bool:
	return _attemptMove(player, Vector2(0, -1))


func attemptMoveRight(player: int) -> bool:
	return _attemptMove(player, Vector2(0, 1))


func attemptGravity(player: int) -> int:
	var shape: ShapeData = _currentShapeDict[player]
	if (shape == null):
		return -1
	
	# If shape is being stalled, don't try drop it
	if (shape._state == _StateEnum.STALLED):
		return _GravityResultEnum.STALLED
	
	var didMove: bool = _attemptMove(player, Vector2(1, 0))
	if (didMove):
		shape._state = _StateEnum.FALLING
		_playerLockDelayTimerDict[player].stop()
		
		# If cells under shape are set or are edges of the board
		if (!_checkIfUnderShapeFree(player)):
			shape._state = _StateEnum.LOCK_DELAY
			_playerLockDelayTimerDict[player].start()
		
		return _GravityResultEnum.MOVED
	# Shape couldn't move down, prepare to lock it in
	else:
		if (_checkIfUnderShapeFree(player)):
			return _GravityResultEnum.CHECK
		# Schedule shape to be locked in
		if (shape._state == _StateEnum.FALLING):
			shape._state = _StateEnum.LOCK_DELAY
			shape._rotationsLeftUntilLock -= 1
			_playerLockDelayTimerDict[player].start()
			return _GravityResultEnum.LOCK_DELAY
		
		# Shape's lock delay has expired, lock it in
		return _GravityResultEnum.PLACED


func attemptSoftDrop(player: int) -> void:
	attemptGravity(player)
	# Reset the ticker if there is only 1 player for a smoother drop rate
	if _numPlayers == 1:
		$BoardTicker.start()


# Check if the space under a shape is free or not
func _checkIfUnderShapeFree(player: int) -> bool:
	var shape: ShapeData = _currentShapeDict[player]
	if (shape == null):
		return false
	
	_removeShapeFromBoard(shape)
	var canMove: bool = true
	var stateArray: Array = shape.getArray()
	var pos: Vector2 = shape._position + Vector2(1, 0)
	for row in range(0, stateArray.size()):
		for col in range(0, stateArray[row].size()):
			# If there is a block in this part of the stateArray
			if (stateArray[row][col] != CELL_CLEAR_VAL):
				# If that position of the board has a cell or position is out-of-bounds
				if(_board.getCellVal(int(pos[0]) + row, int(pos[1]) + col) in [CELL_LOCKED_IN_VAL, CELL_OOB_VAL]):
					canMove = false
	_addShapeToBoard(shape, player)
	return canMove


func _attemptMove(player: int, move: Vector2) -> bool:
	var shape: ShapeData = _currentShapeDict[player]
	if (shape == null):
		return false
	
	# If move is valid, do it
	_removeShapeFromBoard(shape)
	if _checkValidMove(shape.getArray(), (shape._position + move)):
		shape._position += move
		_addShapeToBoard(shape, player)
		updateGhostShapePositions()
		
		# If shape is in lock delay, each successful move stops the delay timer
		_resetLockDelay(shape, player)
		return true
	
	else:
		# Add shape back to board inplace
		_addShapeToBoard(shape, player)
		return false


func attemptHardDrop(player) -> bool:
	if (_currentShapeDict[player] == null):
		return false
	
	for _i in range(0, _board._boardStateArray.size()):
		var didMove: bool = _attemptMove(player, Vector2(1, 0))
		# Shape couldn't move down
		if (!didMove):
			if (!_checkIfUnderShapeFree(player)):
				lockInShape(player)
				return true
			# Shape hard dropped onto another player's current shape
			else:
				return false
	return false


func attemptRotateLeft(player: int) -> bool:
	return _attemptRotation(player, _rotDirection.LEFT)


func attemptRotateRight(player: int) -> bool:
	return _attemptRotation(player, _rotDirection.RIGHT)


func _attemptRotation(player: int, dir):
	var shape: ShapeData = _currentShapeDict[player]
	if (shape == null):
		return false
	var wallkickData: Dictionary
	
	# Get corresponding wallkick data for the shape type
	match shape._shapeType:
		"I":
			wallkickData = _wallkickDataDict["I"]
		"J", "L", "S", "T", "Z":
			wallkickData = _wallkickDataDict["JLSTZ"]
		# O shape can always "rotate", so don't bother checking it further
		"O":
			_resetLockDelay(shape, player)
			return true
	
	var nextOrientation: int
	var rotShapeArray: Array
	if (dir == _rotDirection.LEFT):
		rotShapeArray = shape.getRotateLeft()
		nextOrientation = int(fposmod(shape._orientation - 1, 4))
	elif (dir == _rotDirection.RIGHT):
		rotShapeArray = shape.getRotateRight() 
		nextOrientation = int(fposmod(shape._orientation + 1, 4))
	
	var oriChange: String = "%d>>%d" % [shape._orientation, nextOrientation]
	
	_removeShapeFromBoard(shape)

	# Loop over the 5 different position offsets for this orientation change
	for offsetArray in wallkickData[oriChange]:
		var offset: Vector2 = Vector2(-1 * offsetArray[1], offsetArray[0])
		
		# Do first valid wallkick position offset
		if _checkValidMove(rotShapeArray, shape._position + offset):
			# Shape successfully rotated
			if (dir == _rotDirection.LEFT):
				shape.doRotateLeft(offset)
			elif (dir == _rotDirection.RIGHT):
				shape.doRotateRight(offset)
			 
			_addShapeToBoard(shape, player)
			updateGhostShapePositions()
			# Successful rotation resets lock delay timer
			_resetLockDelay(shape, player)
			return true
	
	# No wallkicks were valid, add shape back to board inplace
	_addShapeToBoard(shape, player)
	return false


# Reset timer, decrement rotations remaining and lock shape in if there are none left
func _resetLockDelay(shape: ShapeData, player: int):
	_playerLockDelayTimerDict[player].stop()
	if (shape._state == _StateEnum.LOCK_DELAY):
		shape._state = _StateEnum.FALLING
		shape._rotationsLeftUntilLock -= 1
		if (shape._rotationsLeftUntilLock <= 0):
			attemptHardDrop(player)


func _checkValidMove(stateArray: Array, pos: Vector2) -> bool:
	for row in range(0, stateArray.size()):
		for col in range(0, stateArray[row].size()):
			# If there is a block in this part of the stateArray
			if (stateArray[row][col] != CELL_CLEAR_VAL):
				# If that position of the board has a cell or position is out-of-bounds
				if(_board.getCellVal(int(pos[0]) + row, int(pos[1]) + col) != CELL_CLEAR_VAL):
					return false
	return true


func lockInShape(player: int):
	# Set the shape's values to be the lock in state value
	var playerShape: ShapeData = _currentShapeDict[player]
	_addShapeToBoard(playerShape, player, true)
	
	# Temporarily remove every other player shape from the board so row clears
	# do not mess with them
	for p in _playersArray:
		if (p != player):
			if (_currentShapeDict[p]):
				_removeShapeFromBoard(_currentShapeDict[p])
	
	var rowsCleared: Array = _board.checkForFullRows()
	
	if rowsCleared.size() > 0:
		emit_signal("lines_cleared", rowsCleared)
		_board.clearAnyFullRows()
	
	# Re-add other shapes to the board
	for p in _playersArray:
		if (p != player):
			if (_currentShapeDict[p]):
				var shape: ShapeData = _currentShapeDict[p]
				
				var lowestRow: int = shape.getLowestRowNumWithCellPresent()
				# Move shape down 1 for every row that was removed beneath it
				for row in rowsCleared:
					if (lowestRow < row):
						# Add to row position
						shape._position[0] += 1
				
				_addShapeToBoard(shape, p)
		
	# If any rows were cleared
	if (rowsCleared.size() > 0):
		_rowCleared(rowsCleared.size())
		$LineClear.pitch_scale = rand_range(0.9, 1.1)
		$LineClear.play()
		get_node("/root/Main/Bg").doBgSwirlEffect()
	else :
		$LockInShape.pitch_scale = rand_range(0.9, 1.1)
		$LockInShape.play()
	
	# For single player, have a smoother drop in by restarting the gravity timer
	if (_numPlayers == 1):
		restartBoardTicker()
	
	# Allow players to use a HOLD again for the next shape
	_alreadyDidHoldDict[player] = false
	
	_currentShapeDict[player] = null
	
	# Remove ghost shape
	updateGhostShapePositions()
	# Start lock in delay until the next shape
	_playerLockedInTimerDict[player].start()


func _removeShapeFromBoard(shape: ShapeData):
	var stateArray: Array = shape.getArray()
	
	for row in range(0, stateArray.size()):
		for col in range(0, stateArray[row].size()):
			# If there is a block in this part of the stateArray
			if (stateArray[row][col] != CELL_CLEAR_VAL):
				_board.setBoardCellToEmpty(row + int(shape._position[0]), col + int(shape._position[1]))


func _rowCleared(numCleared: int) -> void:
	for _i in range(0, numCleared):
		_linesCleared += 1
		
		# Increase _level by 1 for every 10 lines cleared, up to the MAX_LEVEL
		if (_linesCleared % 10 == 0 && _level <= MAX_LEVEL):
			_level += 1
			emit_signal("level_changed", _level)
			_setTickerSpeedBasedOnLevel()
	
	match numCleared:
		1:
			_score += 10 * _level
		2:
			_score += 30 * _level
		3:
			_score += 50 * _level
		4:
			_score += 80 * _level
	
	emit_signal("lines_cleared_changed", _linesCleared)
	emit_signal("score_changed", _score)


func _setTickerSpeedBasedOnLevel() -> void:
	$BoardTicker.set_wait_time( pow(0.8 - ((_level-1) * 0.007), (_level - 1)))


func _addShapeToBoard(shape: ShapeData, player: int, lockIn: bool=false):
	var stateArray: Array = shape.getArray()
	
	for row in range(0, stateArray.size()):
		for col in range(0, stateArray[row].size()):
			# If there is a block in this part of the stateArray
			if (stateArray[row][col] != CELL_CLEAR_VAL):
				if (lockIn):
					_board.setBoardCellToColour(row + int(shape._position[0]), col + int(shape._position[1]), shape._material, CELL_LOCKED_IN_VAL)
				else:
					_board.setBoardCellToColour(row + int(shape._position[0]), col + int(shape._position[1]), shape._material, player + RESERVED_NUM_OFFSET)


func gameOver():
	$GameOver.play()
	_gameHasStarted = false
	_gameIsPlaying = false
	
	$BoardTicker.stop()
	
	# Stop lock in timers to prevent multiplayer bug where a new game is started
	# and the new shape is locked in immediately after
	for player in _playersArray:
		_playerLockedInTimerDict[player].stop()
		_playerLockDelayTimerDict[player].stop()
		
	_board.handle_game_over()
	emit_signal("game_over", _score, _linesCleared)


func generateNext7Array() -> Array:
	var array: Array = []
	for shape in _shapeTypes:
		array.append(str(shape))
	array.shuffle()
	return array


func updateGhostShapePositions() -> void:
	for player in _playersArray:
		var shape: ShapeData = _currentShapeDict[player]
		
		# Shape has been placed
		if shape == null:
			emit_signal("updated_ghost_shape", player, [], Vector2(-1, -1))
			return
		
		# Get max valid offset of shape position down in a straight line
		_removeShapeFromBoard(shape)
		var ghostPos: Vector2 = shape._position
		
		for i in range(0, _board._boardStateArray.size()):
			if !_checkValidMove(shape.getArray(), (shape._position + Vector2(i, 0))):
				break
			# Update as most recent valid position
			ghostPos = shape._position + Vector2(i, 0)
		_addShapeToBoard(shape, player)
	
		emit_signal("updated_ghost_shape", player, shape._state2DArray.duplicate(true), ghostPos)


func _on_BoardTicker_timeout() -> void:
	var shapesThatDidntMove: Array = _playersArray.duplicate(true)
	
	var atLeastOneMoved = true
	while (atLeastOneMoved):
		atLeastOneMoved = false
		for player in shapesThatDidntMove:
			# Try do gravity for all players
			var gravResult: int = attemptGravity(player)
			# If shape was not blocked off by another shape
			if (gravResult != _GravityResultEnum.CHECK):
				shapesThatDidntMove.remove(shapesThatDidntMove.find(player))
				atLeastOneMoved = true
				break


func _on_player_lock_delay_timeout(player: int) -> void:
	if (_currentShapeDict[player] == null):
		return
	attemptHardDrop(player)


func _on_player_lock_in_timeout(player: int) -> void:
	nextShape(player)
