extends Control

class_name PlayerGameInfo


var _playerNum: int
var _playerColour: Color = Color(1, 1, 1)
var _controls: Dictionary # key: String keycodeint, val: action
export var unpressedColour: Color


func init(playerNum: int):
	_playerNum = playerNum
	$PlayerName.text = "Player %d" % playerNum
	_loadPlayerControls()
	_playerColour = Color(_loadJson("res://saveData/playerColours.json")[String(playerNum)])
	$BgKeys.modulate = _playerColour
	var icons = $Icons.get_children()
	for icon in icons:
		icon.modulate = unpressedColour


func setHoldBoard(nodes: Array) -> void:
	# Remove old children
	for node in $HoldBoardCont.get_children():
		node.queue_free()
	for node in nodes:
		$HoldBoardCont.add_child(node)


func _loadPlayerControls() -> void:
	var allPlayerControls: Dictionary = _loadJson("res://saveData/controls.json")
	_controls = allPlayerControls[String(_playerNum)]
	
	for key in _controls:
		match _controls[key]:
			"softDrop":
				$softDrop/Label.text = _getKeyDispString(key)
			
			"hardDrop":
				$hardDrop/Label.text = _getKeyDispString(key)
			
			"left":
				$left/Label.text = _getKeyDispString(key)
			
			"right":
				$right/Label.text = _getKeyDispString(key)
			
			"rotateLeft":
				$rotateLeft/Label.text = _getKeyDispString(key)
			
			"rotateRight":
				$rotateRight/Label.text = _getKeyDispString(key)
			
			"hold":
				$hold/Label.text = _getKeyDispString(key)


func _getKeyDispString(key: String) -> String:
	var dispStr: String = OS.get_scancode_string(int(key))
	
	# Shorten keypad key strings from "Kp n" to "Kn" to fit UI better
	if("Kp " in dispStr):
		return "K" + dispStr[3]
	else:
		return dispStr
	


func _input(ev: InputEvent) -> void:
	if ev is InputEventKey and not ev.echo:
		if (String(ev.scancode)) in _controls:
			# Match key pressed with its corresponding action
			match _controls[String(ev.scancode)]:
				"softDrop":
					if (ev.pressed):
						$Icons/softDrop.modulate = _playerColour
					else:
						$Icons/softDrop.modulate = unpressedColour
				
				"hardDrop":
					if (ev.pressed):
						$Icons/hardDrop.modulate = _playerColour
					else:
						$Icons/hardDrop.modulate = unpressedColour


				"left":
					if (ev.pressed):
						$Icons/left.modulate = _playerColour
					else:
						$Icons/left.modulate = unpressedColour


				"right":
					if (ev.pressed):
						$Icons/right.modulate = _playerColour
					else:
						$Icons/right.modulate = unpressedColour


				"rotateLeft":
					if (ev.pressed):
						$Icons/rotateLeft.modulate = _playerColour
					else:
						$Icons/rotateLeft.modulate = unpressedColour


				"rotateRight":
					if (ev.pressed):
						$Icons/rotateRight.modulate = _playerColour
					else:
						$Icons/rotateRight.modulate = unpressedColour


				"hold":
					if (ev.pressed):
						$Icons/hold.modulate = _playerColour
					else:
						$Icons/hold.modulate = unpressedColour


func _loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict
