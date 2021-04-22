extends Control

class_name PlayerGameInfo


var _playerNum: int


func init(playerNum: int):
	_playerNum = playerNum
	$PlayerName.text = "Player %d" % playerNum
	_loadPlayerControls()
	

func setHoldBoard(nodes: Array) -> void:
	# Remove old children
	for node in $HoldBoardCont.get_children():
		node.queue_free()
	for node in nodes:
		$HoldBoardCont.add_child(node)


func _loadPlayerControls() -> void:
	var allPlayerControls: Dictionary = _loadJson("res://saveData/controls.json")
	var controls: Dictionary = allPlayerControls[String(_playerNum)]
	
	for key in controls:
		match controls[key]:
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
	


func _loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict