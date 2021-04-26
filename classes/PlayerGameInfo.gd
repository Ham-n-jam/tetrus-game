extends Control

class_name PlayerGameInfo


var _playerNum: int
var _playerColour: Color
var _controls: Dictionary # key: String keycodeint, val: action


func init(playerNum: int):
	_playerNum = playerNum
	$PlayerName.text = "Player %d" % playerNum
	_loadPlayerControls()
	_playerColour = Color(_loadJson("res://saveData/playerColours.json")[String(playerNum)])
	$Bg.modulate = _playerColour

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
						$Bg/softDrop.visible = true
					else:
						$Bg/softDrop.visible = false
				
				"hardDrop":
					if (ev.pressed):
						$Bg/hardDrop.visible = true
					else:
						$Bg/hardDrop.visible = false


				"left":
					if (ev.pressed):
						$Bg/left.visible = true
					else:
						$Bg/left.visible = false


				"right":
					if (ev.pressed):
						$Bg/right.visible = true
					else:
						$Bg/right.visible = false


				"rotateLeft":
					if (ev.pressed):
						$Bg/rotateLeft.visible = true
					else:
						$Bg/rotateLeft.visible = false


				"rotateRight":
					if (ev.pressed):
						$Bg/rotateRight.visible = true
					else:
						$Bg/rotateRight.visible = false


				"hold":
					if (ev.pressed):
						$Bg/hold.visible = true
					else:
						$Bg/hold.visible = false


func _loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict
