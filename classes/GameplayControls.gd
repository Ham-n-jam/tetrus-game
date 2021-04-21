extends Node

const DELAY_AUTO_SHIFT_SECS: float = 0.2
const AUTO_SHIFT_SECS: float = 0.03

enum _DirectionEnum {LEFT, RIGHT}

var _players: Array = []
var _playerDelayAutoShiftTimerDict: Dictionary # Key: playerInt, Val: Timer
var _playerAutoShiftTimerDict: Dictionary # Key: playerInt, Val: Timer
var _playerControlsDict: Dictionary # Key: playerInt, Val: Dict<string, int>
var _playerLastPressedDirectionDict: Dictionary # Key: playerInt, Val: int (_DirectionEnum)
var _gameplay: Gameplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_playerControlsDict = _loadJson("res://saveData/controls.json")


func init(numPlayers: int, gameplay: Gameplay) -> void:
	_gameplay = gameplay
	
	for player in range(1, numPlayers + 1):
		_players.append(player)
		
		# Add lock delay timers for each player
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


# Delay before repeated moves kick in
func _on_delay_auto_shift_timeout(player: int):
	_playerAutoShiftTimerDict[player].start()


func _on_auto_shift_timeout(player: int):
	match _playerLastPressedDirectionDict[player]:
		_DirectionEnum.LEFT:
			# Check left key is still being held
			if (Input.is_key_pressed(_getKeyForAction(player, "left"))):
				_gameplay.attemptMoveLeft(player)
			
			# Else if the left key got released but right is still held 
			elif (Input.is_key_pressed(_getKeyForAction(player, "right"))):
				_gameplay.attemptMoveRight(player)
		
		_DirectionEnum.RIGHT:
			# Check left key is still being held
			if (Input.is_key_pressed(_getKeyForAction(player, "right"))):
				_gameplay.attemptMoveRight(player)
				
			# Else if the right key got released but left is still held 
			elif (Input.is_key_pressed(_getKeyForAction(player, "left"))):
				_gameplay.attemptMoveLeft(player)


func _input(ev):
	if ev is InputEventKey and not ev.echo:
		for player in _players:
			# Check if they keypress belongs to this player's controls
			if (ev.pressed and String(ev.scancode) in _playerControlsDict[String(player)]):
				# Match key pressed with its corresponding action
				match _playerControlsDict[String(player)][String(ev.scancode)]:
					"softDrop":
						_gameplay.attemptGravity(player)
					
					"hardDrop":
						_gameplay.attemptHardDrop(player)
					
					"left":
						_playerAutoShiftTimerDict[player].stop()
						_playerDelayAutoShiftTimerDict[player].start()
						_playerLastPressedDirectionDict[player] = _DirectionEnum.LEFT
						_gameplay.attemptMoveLeft(player)
					
					"right":
						_playerAutoShiftTimerDict[player].stop()
						_playerDelayAutoShiftTimerDict[player].start()
						_playerLastPressedDirectionDict[player] = _DirectionEnum.RIGHT
						_gameplay.attemptMoveRight(player)
					
					"rotateLeft":
						_gameplay.attemptRotateLeft(player)
					
					"rotateRight":
						_gameplay.attemptRotateRight(player)
					
					"hold":
						_gameplay.attemptHold(player)


# Get the button keycode int that corresponds to the action
func _getKeyForAction(player: int, action: String):
	var controls: Dictionary = _playerControlsDict[String(player)]
	
	for key in controls:
		if controls[key] == action:
			return int(key)
	
	return -1


func _loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict
