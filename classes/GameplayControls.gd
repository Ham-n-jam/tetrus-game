extends Node

const DELAY_AUTO_SHIFT_SECS: float = 0.12
const AUTO_SHIFT_SECS: float = 0.05
const SOFT_DROP_SPEED: float = 0.03

enum _DirectionEnum {LEFT, RIGHT}

var _players: Array = []
var _playerDelayAutoShiftTimerDict: Dictionary # Key: playerInt, Val: Timer
var _playerAutoShiftTimerDict: Dictionary # Key: playerInt, Val: Timer
var _playerSoftDropTimerDict: Dictionary # Key: playerInt, Val: Timer
var _playerControlsDict: Dictionary # Key: playerInt, Val: Dict<string, int>
var _playerLastPressedDirectionDict: Dictionary # Key: playerInt, Val: int (_DirectionEnum)
var _gameplay: Gameplay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_playerControlsDict = GlobalFunc.loadJson("res://saveData/controls.json")


func init(numPlayers: int, gameplay: Gameplay) -> void:
	_gameplay = gameplay
	
	for player in range(1, numPlayers + 1):
		_players.append(player)
		
		# Add delay timers for each player
		var delayAutoShiftTimer = Timer.new()
		add_child(delayAutoShiftTimer)
		delayAutoShiftTimer.set_one_shot(true)
		delayAutoShiftTimer.set_wait_time(DELAY_AUTO_SHIFT_SECS)
		delayAutoShiftTimer.connect("timeout", self, "_on_delay_auto_shift_timeout", [player])
		_playerDelayAutoShiftTimerDict[player] = delayAutoShiftTimer
		
		var autoShiftTimer = Timer.new()
		add_child(autoShiftTimer)
		autoShiftTimer.set_wait_time(AUTO_SHIFT_SECS)
		autoShiftTimer.connect("timeout", self, "_on_auto_shift_timeout", [player])
		_playerAutoShiftTimerDict[player] = autoShiftTimer
		
		var softDropTimer = Timer.new()
		add_child(softDropTimer)
		softDropTimer.set_wait_time(AUTO_SHIFT_SECS)
		softDropTimer.connect("timeout", self, "_on_soft_drop_timeout", [player])
		_playerSoftDropTimerDict[player] = softDropTimer


func _input(ev):

	if ev is InputEventKey and not ev.echo:
		for player in _players:
			# Check if they keypress belongs to this player's controls
			if (String(ev.scancode) in _playerControlsDict[String(player)]):
				# Match key pressed with its corresponding action
				match _playerControlsDict[String(player)][String(ev.scancode)]:
					"softDrop":
						if (ev.pressed):
							if _gameplay._gameIsPlaying:
								_gameplay.attemptSoftDrop(player)
							_playerSoftDropTimerDict[player].start()
						else:
							# Stop soft dropping on key release
							_playerSoftDropTimerDict[player].stop()
					
					"hardDrop":
						if (ev.pressed):
							if _gameplay._gameIsPlaying:
								_gameplay.attemptHardDrop(player)
					
					"left":
						if (ev.pressed):
							_handleLeftRightInput(player, _DirectionEnum.LEFT)
					
					"right":
						if (ev.pressed):
							_handleLeftRightInput(player, _DirectionEnum.RIGHT)
					
					"rotateLeft":
						if (ev.pressed):
							if _gameplay._gameIsPlaying:
								_gameplay.attemptRotateLeft(player)
					
					"rotateRight":
						if (ev.pressed):
							if _gameplay._gameIsPlaying:
								_gameplay.attemptRotateRight(player)
					
					"hold":
						if (ev.pressed):
							if _gameplay._gameIsPlaying:
								_gameplay.attemptHold(player)


func _handleLeftRightInput(player: int, direction: int):
		# Prepare to handle held inputs
		_playerAutoShiftTimerDict[player].stop()
		_playerDelayAutoShiftTimerDict[player].start()
		
		if (direction == _DirectionEnum.LEFT):
			_playerLastPressedDirectionDict[player] = _DirectionEnum.LEFT
			if _gameplay._gameIsPlaying:
				_gameplay.attemptMoveLeft(player)
		
		elif (direction == _DirectionEnum.RIGHT):
			_playerLastPressedDirectionDict[player] = _DirectionEnum.RIGHT
			if _gameplay._gameIsPlaying:
				_gameplay.attemptMoveRight(player)


# Delay before autoshift kicks in
func _on_delay_auto_shift_timeout(player: int):
	_playerAutoShiftTimerDict[player].start()


# Autoshift/held press behaviour
func _on_auto_shift_timeout(player: int):
	if _gameplay._gameIsPlaying:
		match _playerLastPressedDirectionDict[player]:
			_DirectionEnum.LEFT:
				# Check left key is still being held
				if (Input.is_key_pressed(_getKeyForAction(player, "left"))):
					_gameplay.attemptMoveLeft(player)
				
				# Else if the left key got released but right is still held 
				elif (Input.is_key_pressed(_getKeyForAction(player, "right"))):
					_handleLeftRightInput(player, _DirectionEnum.RIGHT)
			
			_DirectionEnum.RIGHT:
				# Check left key is still being held
				if (Input.is_key_pressed(_getKeyForAction(player, "right"))):
					_gameplay.attemptMoveRight(player)
					
				# Else if the right key got released but left is still held 
				elif (Input.is_key_pressed(_getKeyForAction(player, "left"))):
					_handleLeftRightInput(player, _DirectionEnum.LEFT)


func _on_soft_drop_timeout(player: int):
	if _gameplay._gameIsPlaying:
		_gameplay.attemptSoftDrop(player)


# Get the button keycode int that corresponds to the action
func _getKeyForAction(player: int, action: String):
	var controls: Dictionary = _playerControlsDict[String(player)]
	
	for key in controls:
		if controls[key] == action:
			return int(key)
	
	return -1

