extends MenuOption

var _playerNum: int = 1 setget setPlayerNum
export var button: String setget setButton
export var actionDesc: String setget setActionDesc
export var action: String
var _isListening: bool = false
var _players: Array = [1, 2, 3, 4]
var _playerControlsDict: Dictionary # Key: playerInt, Val: Dict<string, int>

signal key_mapping_changed

func _ready():
	_playerControlsDict = GlobalFunc.loadJson("res://saveData/controls.json")
	$Listening.visible = false
	$Warning.visible = false


func setPlayerNum(value: int):
	_playerNum = value
	var thisPlayersControls: Dictionary = _playerControlsDict[str(_playerNum)]
	for scancodeKey in thisPlayersControls.keys():
		var actionVal: String = thisPlayersControls[scancodeKey]
		if actionVal == action:
			self.button = GlobalFunc.getKeyDispString(int(scancodeKey))


func setButton(value: String) -> void:
	button = value
	$Label.text = value


func setActionDesc(value: String) -> void:
	actionDesc = value
	$Label/Desc.text = value


func onClick() -> bool:
	_playerControlsDict = GlobalFunc.loadJson("res://saveData/controls.json")
	_isListening = true
	$Listening.visible = true
	$Warning.visible = false
	return true


func remapButton(scancode: int) -> void:
	self.button = GlobalFunc.getKeyDispString(scancode)
	var errorKey: String
	for player in _players:
		# Check if the control is already in use by another player
		if (player != _playerNum and (str(scancode) in _playerControlsDict[str(player)])):
			match _playerControlsDict[str(player)][str(scancode)]:
				"softDrop":
					errorKey = "Soft Drop"
				"hardDrop":
					errorKey = "Hard Drop"
				"left":
					errorKey = "Move Left"
				"right":
					errorKey = "Move Right"
				"rotateLeft":
					errorKey = "Rotate Left"
				"rotateRight":
					errorKey = "Rotate Right"
				"hold":
					errorKey = "Hold"
			$Warning/Error.text = "Key matches P" + str(player) + "'s " + errorKey
			$Warning.visible = true
		else:
			if errorKey == null || errorKey == "":
				$Warning.visible = false
	
	var thisPlayersControls: Dictionary = _playerControlsDict[str(_playerNum)]
	if thisPlayersControls.has(str(scancode)) and thisPlayersControls[str(scancode)] != action:
		$Warning/Error.text = "Duplicate key"
		$Warning.visible = true
	
	# Save the key in the .json file
	for scancodeKey in thisPlayersControls.keys():
		var actionVal: String = thisPlayersControls[scancodeKey]
		if actionVal == action:
			# Remove old key-value pair
			thisPlayersControls.erase(scancodeKey)
			break
	thisPlayersControls[str(scancode)] = action
	_playerControlsDict[str(_playerNum)] = thisPlayersControls
	GlobalFunc.saveJson("res://saveData/controls.json", _playerControlsDict)
	emit_signal("key_mapping_changed")


func handleInput(ev: InputEvent) -> bool:
		if ev is InputEventKey and ev.pressed and _isListening:
			if ev.scancode != KEY_BACKSPACE:
				remapButton(ev.scancode)
		_isListening = false
		$Listening.visible = false
		return false


func _process(delta):
	if _isListening:
		$Bg.modulate = Color.deepskyblue
